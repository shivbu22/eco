import { createApp } from "./app.js";

const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3002;
const server = createApp();
server.listen(PORT, () => {
  console.log(`Booking Service listening on port ${PORT}`);
});
