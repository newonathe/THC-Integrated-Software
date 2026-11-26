import { describe, expect, it } from 'vitest';
import {
  centavosFromDb,
  centavosToPesos,
  costCentavosToPesos,
  pesosToCentavos,
  sumCentavos
} from '@/lib/money';
import { PRODUCTS } from '@/store/engine/ops-engine';

/**
 * The conversion boundary. Every price, total and ledger entry crosses it, so an error
 * here is an error in her books rather than on one screen.
 */
describe('pesosToCentavos', () => {
  it('converts the packaging fee without losing the centavo that float maths eats', () => {
    // 19.99 * 100 is 1998.9999999999998 in IEEE-754. Truncating loses a centavo on
    // every box, forever. This assertion is the reason Math.round is not optional.
    expect(pesosToCentavos(19.99)).toBe(1999);
  });

  it('converts every seeded price losslessly, both ways', () => {
    for (const product of PRODUCTS) {
      const centavos = pesosToCentavos(product.price);
      expect(Number.isInteger(centavos)).toBe(true);
      expect(centavosToPesos(centavos)).toBe(product.price);
    }
  });

  it('handles a whole-peso price exactly', () => {
    expect(pesosToCentavos(130)).toBe(13000);
    expect(pesosToCentavos(900)).toBe(90000);
  });

  it('handles zero and a refund', () => {
    expect(pesosToCentavos(0)).toBe(0);
    expect(pesosToCentavos(-1200)).toBe(-120000);
  });

  it('refuses a value that is not a number rather than storing NaN', () => {
    expect(() => pesosToCentavos(Number.NaN)).toThrow(TypeError);
    expect(() => pesosToCentavos(Number.POSITIVE_INFINITY)).toThrow(TypeError);
  });
});

describe('centavosToPesos', () => {
  it('refuses a fractional centavo, so the bad conversion is found where it happened', () => {
    expect(() => centavosToPesos(1999.5)).toThrow(TypeError);
  });
});

describe('centavosFromDb', () => {
  it('accepts the string Postgres actually returns for a bigint column', () => {
    expect(centavosFromDb('13000')).toBe(13000);
  });

  it('treats a null column as zero rather than NaN', () => {
    expect(centavosFromDb(null)).toBe(0);
  });

  it('refuses a value that has lost precision', () => {
    expect(() => centavosFromDb('9007199254740993')).toThrow(TypeError);
  });
});

describe('sumCentavos', () => {
  it('adds a day of takings exactly, which summing pesos would not', () => {
    const prices = PRODUCTS.map((p) => pesosToCentavos(p.price));
    const total = sumCentavos([...prices, ...prices, 1999]);
    expect(Number.isInteger(total)).toBe(true);
    expect(total).toBe(prices.reduce((a, b) => a + b, 0) * 2 + 1999);
  });

  it('is zero for an empty day', () => {
    expect(sumCentavos([])).toBe(0);
  });
});

describe('costCentavosToPesos', () => {
  it('converts a fractional cost rate, the one place the database cost reads cross', () => {
    expect(costCentavosToPesos(1234.5678)).toBeCloseTo(12.345678, 9);
    expect(costCentavosToPesos('0.42')).toBeCloseTo(0.0042, 9);
    expect(costCentavosToPesos(null)).toBeNull();
    expect(costCentavosToPesos(Number.NaN)).toBeNull();
  });
});
