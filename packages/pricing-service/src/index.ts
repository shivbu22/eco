// Pricing Service — entry point
import { createApp } from "./app.js";

export { storePricingRule, updatePricingRule, getActiveRule, computeTotal } from "./pricing.js";

const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3004;

const server = createApp();
server.listen(PORT, () => {
  console.log(`[pricing-service] Listening on port ${PORT}`);
});
