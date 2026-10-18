import { describe, it, expect } from "vitest";
import { getServiceCategories, getSubServices } from "./home";

describe("getServiceCategories", () => {
  it("returns all 5 required categories", () => {
    const cats = getServiceCategories();
    expect(cats).toHaveLength(5);
    expect(cats).toContain("Cleaning");
    expect(cats).toContain("Waste Management");
    expect(cats).toContain("Logistics");
    expect(cats).toContain("B2B Services");
    expect(cats).toContain("Recycling");
  });

  it("returns a new array each call (immutable source)", () => {
    const a = getServiceCategories();
    const b = getServiceCategories();
    expect(a).not.toBe(b);
    expect(a).toEqual(b);
  });
});

describe("getSubServices", () => {
  it("returns sub-services for Cleaning", () => {
    const subs = getSubServices("Cleaning");
    expect(subs.length).toBeGreaterThan(0);
    for (const s of subs) {
      expect(s).toHaveProperty("id");
      expect(s).toHaveProperty("name");
      expect(s).toHaveProperty("description");
      expect(typeof s.basePrice).toBe("number");
    }
  });

  it("returns sub-services for every category", () => {
    const cats = getServiceCategories();
    for (const cat of cats) {
      const subs = getSubServices(cat);
      expect(subs.length).toBeGreaterThan(0);
    }
  });

  it("returns empty array for unknown category", () => {
    expect(getSubServices("Unknown")).toEqual([]);
  });
});
