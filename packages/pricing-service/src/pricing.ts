import { randomUUID } from "crypto";
import type { PricingRule } from "@ecomins/shared";

// In-memory store: all pricing rules
const pricingStore = new Map<string, PricingRule>();

// --- Core logic functions (exported for testing) ---

export function storePricingRule(input: {
  service_type: string;
  zone_id: string;
  base_rate: number;
  tax_rate: number;
  surcharge: number;
}): PricingRule {
  const rule: PricingRule = {
    id: randomUUID(),
    service_type: input.service_type,
    zone_id: input.zone_id,
    base_rate: input.base_rate,
    tax_rate: input.tax_rate,
    surcharge: input.surcharge,
    effective_from: new Date().toISOString(),
  };
  pricingStore.set(rule.id, rule);
  return rule;
}

export function updatePricingRule(
  id: string,
  updates: Partial<Pick<PricingRule, "base_rate" | "tax_rate" | "surcharge">>
): PricingRule | null {
  const existing = pricingStore.get(id);
  if (!existing) return null;

  // Create a new rule entry with a new id and updated effective_from.
  // The old rule stays in the store so temporal queries at past timestamps
  // still resolve to the original price (Requirement 13.3).
  const updated: PricingRule = {
    ...existing,
    ...updates,
    id: randomUUID(),
    effective_from: new Date().toISOString(),
  };
  pricingStore.set(updated.id, updated);
  return updated;
}

/**
 * Returns the active rule for a given service_type + zone_id at a specific point in time.
 * "Active" means the rule with the latest effective_from that is ≤ asOf.
 */
export function getActiveRule(
  service_type: string,
  zone_id: string,
  asOf: Date = new Date()
): PricingRule | null {
  const candidates = Array.from(pricingStore.values()).filter(
    (r) =>
      r.service_type === service_type &&
      r.zone_id === zone_id &&
      new Date(r.effective_from) <= asOf
  );

  if (candidates.length === 0) return null;

  // Return the one with the latest effective_from
  return candidates.reduce((best, r) =>
    new Date(r.effective_from) > new Date(best.effective_from) ? r : best
  );
}

/**
 * Computes total price: base_rate * (1 + tax_rate) + surcharge
 */
export function computeTotal(rule: PricingRule): number {
  return rule.base_rate * (1 + rule.tax_rate) + rule.surcharge;
}

// --- Store helpers for testing ---

export function _clearPricingStore(): void {
  pricingStore.clear();
}

export function _getPricingStore(): Map<string, PricingRule> {
  return pricingStore;
}
