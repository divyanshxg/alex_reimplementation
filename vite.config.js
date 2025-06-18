// vite.config.js
import glsl from "vite-plugin-glsl";
import { defineConfig } from "vite";

export default defineConfig({
  server: {
    host: '0.0.0.0', // Listen on all network interfaces
    port: 5173,      // Default Vite port
    // open: true,    // Uncomment to automatically open in your default browser (might not work as expected on phone)
  },
  plugins: [glsl()],
});
