import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

/**
 * A queued sale is only "saved" once its IndexedDB transaction has completed: a request can succeed and the
 * transaction still abort (a full disk, the browser closing it). Runs the real wrapper over a hand-driven database.
 */
type Handler = ((event?: unknown) => void) | null;
interface FakeRequest {
  result: unknown;
  error: unknown;
  onsuccess: Handler;
  onerror: Handler;
  onupgradeneeded?: Handler;
}
interface FakeTransaction {
  error: unknown;
  oncomplete: Handler;
  onabort: Handler;
  onerror: Handler;
  request: FakeRequest;
}
const request = (): FakeRequest => ({
  result: undefined,
  error: null,
  onsuccess: null,
  onerror: null
});

let opens: FakeRequest[];
let transactions: FakeTransaction[];
let closed: number;
let refuseTransaction: boolean;
function database() {
  return {
    objectStoreNames: { contains: () => true },
    onversionchange: null as Handler,
    onclose: null as Handler,
    close: () => void closed++,
    transaction: () => {
      if (refuseTransaction) throw new DOMException('closing', 'InvalidStateError');
      const t: FakeTransaction = {
        error: null,
        oncomplete: null,
        onabort: null,
        onerror: null,
        request: request()
      };
      transactions.push(t);
      const store = { put: () => t.request, getAll: () => t.request, delete: () => t.request };
      return Object.assign(t, { objectStore: () => store });
    }
  };
}
const turn = () => new Promise((resolve) => setTimeout(resolve, 0));
async function opened(index = 0) {
  await turn();
  const db = database();
  opens[index].result = db;
  opens[index].onsuccess?.();
  await turn();
  return db;
}
/** What a promise has done so far, without waiting for it. */
async function state(promise: Promise<unknown>) {
  let now = 'pending';
  promise.then(
    () => (now = 'saved'),
    () => (now = 'failed')
  );
  await turn();
  return now;
}

beforeEach(() => {
  opens = [];
  transactions = [];
  closed = 0;
  refuseTransaction = false;
  vi.resetModules();
  vi.stubGlobal('indexedDB', {
    open: () => {
      const r = request();
      opens.push(r);
      return r;
    }
  });
});
afterEach(() => vi.unstubAllGlobals());

const load = async () => (await import('@/lib/offline/idb')).idb;

describe('saving a queued sale on the device', () => {
  it('is not saved when only the request has succeeded', async () => {
    const idb = await load();
    const put = idb.put({ clientId: 'a' });
    await opened();
    transactions[0].request.onsuccess?.();
    expect(await state(put)).toBe('pending');
    transactions[0].oncomplete?.();
    expect(await state(put)).toBe('saved');
  });

  it('fails when the transaction aborts after the request succeeded', async () => {
    const idb = await load();
    const put = idb.put({ clientId: 'a' });
    put.catch(() => undefined);
    await opened();
    transactions[0].request.onsuccess?.();
    transactions[0].error = new DOMException('full', 'QuotaExceededError');
    transactions[0].onabort?.();
    await expect(put).rejects.toMatchObject({ name: 'QuotaExceededError' });
  });

  it('fails with a reason when a transaction aborts without an error of its own', async () => {
    const idb = await load();
    const put = idb.put({ clientId: 'a' });
    put.catch(() => undefined);
    await opened();
    transactions[0].onabort?.();
    await expect(put).rejects.toMatchObject({ name: 'AbortError' });
  });

  it('returns what was read once the read has completed', async () => {
    const idb = await load();
    const all = idb.all();
    await opened();
    transactions[0].request.result = [{ clientId: 'a' }];
    transactions[0].request.onsuccess?.();
    transactions[0].oncomplete?.();
    await expect(all).resolves.toEqual([{ clientId: 'a' }]);
  });
});

describe('opening the device store', () => {
  it('tries again after a failed open', async () => {
    const idb = await load();
    const first = idb.all();
    first.catch(() => undefined);
    await turn();
    opens[0].error = new DOMException('no', 'UnknownError');
    opens[0].onerror?.();
    await expect(first).rejects.toMatchObject({ name: 'UnknownError' });
    void idb.all();
    await turn();
    expect(opens).toHaveLength(2);
  });

  it('opens again after the browser closed the connection', async () => {
    const idb = await load();
    void idb.all();
    const db = await opened();
    db.onclose?.();
    void idb.all();
    await turn();
    expect(opens).toHaveLength(2);
  });

  it('lets go of the connection when another tab needs to change the store', async () => {
    const idb = await load();
    void idb.all();
    const db = await opened();
    db.onversionchange?.();
    expect(closed).toBe(1);
    void idb.all();
    await turn();
    expect(opens).toHaveLength(2);
  });

  it('opens again after a connection refuses a transaction', async () => {
    const idb = await load();
    const first = idb.put({ clientId: 'a' });
    first.catch(() => undefined);
    refuseTransaction = true;
    await opened();
    await expect(first).rejects.toMatchObject({ name: 'InvalidStateError' });
    void idb.all();
    await turn();
    expect(opens).toHaveLength(2);
  });
});
