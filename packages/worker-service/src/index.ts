// Worker Management Service — entry point
import { createApp } from "./app.js";

const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3003;

const server = createApp();
server.listen(PORT, () => {
  console.log(`Worker Management Service listening on port ${PORT}`);
});
