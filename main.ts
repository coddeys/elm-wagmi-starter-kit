import "./style.css";
import { Elm } from "./src/Main.elm";
import {
  connect,
  disconnect,
  getChains,
  getChainId,
  getAccount,
  getEnsName,
} from "@wagmi/core";
import { config } from "./config";
import { metaMask } from "@wagmi/connectors";

const root = document.querySelector("#app");
const app = Elm.Main.init({ node: root, flags: {} });

app.ports.connectWallet.subscribe(() => {
  connectMetaMask();
});

app.ports.disconnectWallet.subscribe(() => {
  disconnectMetaMask();
});

async function connectMetaMask() {
  try {
    await connect(config, { connector: metaMask() });
  } catch (e) {
    // getting some weird error
    // TypeError: Cannot read properties of undefined (reading 'on')
    // at Object.connect (metaMask.ts:70:18)
    await connect(config, { connector: metaMask() });
  }
  const { address } = getAccount(config);
  const chainId = getChainId(config);
  const chains = getChains(config);
  console.log(chainId);
  console.log(chains);

  app.ports.addressReceived.send({ chainId, address });
}

async function disconnectMetaMask() {
  await disconnect(config);
}
