// Customer App — Home screen logic
// Requirements: 2.1, 2.2, 2.3

export type ServiceCategory =
  | "Cleaning"
  | "Waste Management"
  | "Logistics"
  | "B2B Services"
  | "Recycling";

export interface SubService {
  id: string;
  name: string;
  description: string;
  basePrice: number;
}

const SERVICE_CATEGORIES: ServiceCategory[] = [
  "Cleaning",
  "Waste Management",
  "Logistics",
  "B2B Services",
  "Recycling",
];

const SUB_SERVICES: Record<ServiceCategory, SubService[]> = {
  Cleaning: [
    { id: "cleaning-home", name: "Home Cleaning", description: "Full home cleaning service", basePrice: 500 },
    { id: "cleaning-office", name: "Office Cleaning", description: "Commercial office cleaning", basePrice: 1200 },
    { id: "cleaning-eco", name: "Eco Cleaning", description: "Eco-friendly cleaning with green products", basePrice: 700 },
  ],
  "Waste Management": [
    { id: "waste-garbage", name: "Garbage Collection", description: "Scheduled garbage pickup", basePrice: 200 },
    { id: "waste-bulk", name: "Bulk Waste Removal", description: "Large item and bulk waste disposal", basePrice: 800 },
  ],
  Logistics: [
    { id: "logistics-transport", name: "Waste Transport", description: "Transport waste to disposal facility", basePrice: 600 },
    { id: "logistics-delivery", name: "Material Delivery", description: "Delivery of recycling materials", basePrice: 400 },
  ],
  "B2B Services": [
    { id: "b2b-contract", name: "Monthly Contract", description: "Recurring sanitation contract for businesses", basePrice: 5000 },
    { id: "b2b-society", name: "Society Package", description: "Residential society waste management", basePrice: 3000 },
  ],
  Recycling: [
    { id: "recycling-scrap", name: "Scrap Metal Pickup", description: "Collect and monetize scrap metal", basePrice: 0 },
    { id: "recycling-paper", name: "Paper Recycling", description: "Paper and cardboard collection", basePrice: 0 },
    { id: "recycling-plastic", name: "Plastic Recycling", description: "Plastic waste collection", basePrice: 0 },
    { id: "recycling-ewaste", name: "E-Waste Collection", description: "Electronic waste pickup and recycling", basePrice: 0 },
  ],
};

/**
 * Returns all available service categories.
 * Requirement 2.1: display Cleaning, Waste Management, Logistics, B2B Services, Recycling.
 */
export function getServiceCategories(): ServiceCategory[] {
  return [...SERVICE_CATEGORIES];
}

/**
 * Returns sub-services for a given category.
 * Requirement 2.2: display sub-services with name, description, and base price.
 */
export function getSubServices(category: string): SubService[] {
  const key = category as ServiceCategory;
  return SUB_SERVICES[key] ?? [];
}
