import { http, createConfig } from "@wagmi/core";
import { metaMask } from "@wagmi/connectors";
import { mainnet, arbitrum } from "@wagmi/core/chains";

export const config = createConfig({
  chains: [mainnet, arbitrum],
  connectors: [metaMask()],
  transports: {
    [mainnet.id]: http(),
    [arbitrum.id]: http(),
  },
});
