import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { act } from 'react';
import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { CustomersLive } from '@/components/live/sell/customers-live';
import { ordersRead, type OrdersReadSnapshot } from '@/lib/orders/orders-read-state';
import { STAFF_COPY } from '@/lib/orders/staff-copy';
import type { CustomerRow } from '@/store/customer-desk';
import type { OpsVals } from '@/view-models/vals';
import { setReducedMotion } from './ui-helpers';

const reader = {};
const retry = vi.fn();
const tell = vi.fn();
const now = Date.parse('2026-11-10T02:00:00Z');
const customer: CustomerRow = {
  key: 'test-customer',
  name: 'Synthetic customer',
  mobile: '',
  contactText: '',
  orderCountText: '1 order',
  lastOrderText: 'Last order Tue, Nov 10',
  orders: [],
  recordCsv: ''
};

function snapshot(over: Partial<OrdersReadSnapshot> = {}) {
  ordersRead.publish(reader, {
    phase: 'read',
    everRead: true,
    readAt: now,
    dropped: 0,
    savedNotRefreshed: null,
    retry,
    ...over
  });
}

function vals(loaded = true, rows: CustomerRow[] = [customer]): OpsVals {
  return {
    ownerView: true,
    liveCustomers: { loaded, rows, online: true, removeContact: vi.fn() },
    waitlist: [{ name: 'Synthetic waitlist', want: '', when: '', contacted: false, go: tell }]
  } as unknown as OpsVals;
}

beforeEach(() => {
  setReducedMotion(true);
  vi.useFakeTimers({ toFake: ['Date'] });
  vi.setSystemTime(now);
  retry.mockClear();
  tell.mockClear();
  ordersRead.claim(reader);
});

afterEach(() => {
  cleanup();
  ordersRead.reset();
  vi.useRealTimers();
  vi.unstubAllGlobals();
});

describe('Customers reflects the shared staff order read state', () => {
  it('shows an unfinished read without an empty-customer claim', () => {
    snapshot({ phase: 'loading', everRead: false, readAt: null });
    render(<CustomersLive v={vals(false, [])} />);
    expect(screen.getByText(STAFF_COPY.ordersNotRead)).toBeTruthy();
    expect(screen.queryByText('No customers in the orders read.')).toBeNull();
  });

  it('reports first failure, retries, and preserves the separate waitlist', () => {
    snapshot({ phase: 'failed', everRead: false, readAt: null });
    const view = render(<CustomersLive v={vals(false, [])} />);
    expect(screen.getByText(STAFF_COPY.ordersReadFailed)).toBeTruthy();
    expect(screen.queryByText(STAFF_COPY.ordersNotRead)).toBeNull();
    fireEvent.click(screen.getByRole('button', { name: 'Try again' }));
    expect(retry).toHaveBeenCalledOnce();
    fireEvent.click(screen.getByRole('button', { name: 'Tell them' }));
    expect(tell).toHaveBeenCalledOnce();
    act(() => snapshot());
    view.rerender(<CustomersLive v={vals()} />);
    expect(screen.getByText(customer.name)).toBeTruthy();
    expect(screen.queryByText(STAFF_COPY.ordersReadFailed)).toBeNull();
  });

  it('labels stale rows both on the list and in the open detail', () => {
    snapshot({ phase: 'failed' });
    render(<CustomersLive v={vals()} />);
    expect(screen.getByText(STAFF_COPY.ordersStale('10:00 AM'))).toBeTruthy();
    fireEvent.click(screen.getByRole('button', { name: 'Open customer Synthetic customer' }));
    expect(screen.getByText(STAFF_COPY.ordersStale('10:00 AM'))).toBeTruthy();
    fireEvent.click(screen.getByRole('button', { name: 'Try again' }));
    expect(retry).toHaveBeenCalledOnce();
    act(() => snapshot());
    expect(screen.queryByText(STAFF_COPY.ordersStale('10:00 AM'))).toBeNull();
    expect(screen.getByRole('heading', { name: customer.name })).toBeTruthy();
  });

  it('keeps an incomplete empty read distinct from a successful empty read', () => {
    snapshot({ dropped: 2 });
    render(<CustomersLive v={vals(true, [])} />);
    expect(screen.getByText(STAFF_COPY.ordersDropped(2))).toBeTruthy();
    expect(screen.getByText('No customers could be shown from this incomplete read.')).toBeTruthy();
    expect(screen.queryByText('No customers in the orders read.')).toBeNull();
    act(() => snapshot());
    expect(screen.getByText('No customers in the orders read.')).toBeTruthy();
    expect(screen.queryByText(STAFF_COPY.ordersDropped(2))).toBeNull();
  });

  it('describes the bounded order feed and the export in list and detail', () => {
    snapshot();
    render(<CustomersLive v={vals()} />);
    const scope = /Open orders and orders placed in the last 60 days, up to 500 orders/;
    expect(screen.getByText(scope)).toBeTruthy();
    fireEvent.click(screen.getByRole('button', { name: 'Open customer Synthetic customer' }));
    expect(screen.getByText(scope)).toBeTruthy();
    expect(screen.getByRole('heading', { name: 'Orders in this list' })).toBeTruthy();
    expect(screen.getByRole('button', { name: 'Export listed orders' })).toBeTruthy();
  });

  it('keeps a message draft when a refresh changes from good to stale', () => {
    snapshot();
    render(<CustomersLive v={vals()} />);
    fireEvent.click(screen.getByRole('button', { name: 'Open customer Synthetic customer' }));
    fireEvent.click(screen.getByRole('button', { name: 'Prepare message' }));
    fireEvent.change(screen.getByRole('textbox', { name: 'Message' }), {
      target: { value: 'Unsent synthetic draft' }
    });
    act(() => snapshot({ phase: 'failed' }));
    expect(screen.getByText(STAFF_COPY.ordersStale('10:00 AM'))).toBeTruthy();
    expect((screen.getByRole('textbox', { name: 'Message' }) as HTMLTextAreaElement).value).toBe(
      'Unsent synthetic draft'
    );
  });
});
