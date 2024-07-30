import "./style.css";
import { Elm } from "./src/Main.elm";
import { connect, getAccount, getEnsName } from "@wagmi/core";
import { config } from "./config";
import { metaMask } from "@wagmi/connectors";

const root = document.querySelector("#app");
const app = Elm.Main.init({ node: root, flags: {} });

app.ports.connectWallet.subscribe(() => {
  connectMetaMask();
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
  app.ports.addressReceived.send(address);
}
