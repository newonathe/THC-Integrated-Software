/** A tiny promise wrapper over one IndexedDB object store. No dependency, no magic. */
const DB_NAME = 'hc-ops';
const DB_VERSION = 1;
export const SALE_STORE = 'sale-queue';

let dbPromise: Promise<IDBDatabase> | null = null;

function openDb(): Promise<IDBDatabase> {
  if (dbPromise) return dbPromise;
  const opening = new Promise<IDBDatabase>((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION);
    request.onupgradeneeded = () => {
      const db = request.result;
      if (!db.objectStoreNames.contains(SALE_STORE)) {
        const store = db.createObjectStore(SALE_STORE, { keyPath: 'clientId' });
        store.createIndex('by-state', 'state');
      }
    };
    request.onsuccess = () => {
      const db = request.result;
      // A closed connection can never be used again: let go of it, so the next call opens a new one.
      db.onclose = () => forget(opening);
      db.onversionchange = () => {
        forget(opening);
        db.close();
      };
      resolve(db);
    };
    request.onerror = () => {
      forget(opening);
      reject(request.error);
    };
  });
  dbPromise = opening;
  return opening;
}

function forget(opening: Promise<IDBDatabase>): void {
  if (dbPromise === opening) dbPromise = null;
}

async function tx<T>(
  mode: IDBTransactionMode,
  run: (store: IDBObjectStore) => IDBRequest<T>
): Promise<T> {
  const opening = openDb();
  const db = await opening;
  return new Promise<T>((resolve, reject) => {
    let transaction: IDBTransaction;
    try {
      transaction = db.transaction(SALE_STORE, mode);
    } catch (error) {
      forget(opening);
      throw error;
    }
    const request = run(transaction.objectStore(SALE_STORE));
    // Only a completed transaction is on the device: a request can succeed and its transaction still abort.
    transaction.oncomplete = () => resolve(request.result);
    transaction.onabort = () =>
      reject(transaction.error ?? new DOMException('The device did not save it', 'AbortError'));
    request.onerror = () => reject(request.error);
  });
}

export const idb = {
  put: <T>(value: T) => tx('readwrite', (store) => store.put(value) as IDBRequest<IDBValidKey>),
  all: <T>() => tx('readonly', (store) => store.getAll() as IDBRequest<T[]>),
  get: <T>(key: string) => tx('readonly', (store) => store.get(key) as IDBRequest<T | undefined>),
  delete: (key: string) => tx('readwrite', (store) => store.delete(key) as IDBRequest<undefined>),
  supported: () => typeof indexedDB !== 'undefined'
};
