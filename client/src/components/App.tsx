import { Container, Divider, Grid, Image } from "semantic-ui-react";
import { StateProvider } from "../hooks/StateContext";
import { useAccount } from "@starknet-react/core";
import { useDebug } from "../hooks/useDebug";
import { ConnectedHeader, ConnectButton } from "./Connect";
import DojoSetup from "../dojo/DojoSetup";
import Main from "./Main";

const Row = Grid.Row
const Col = Grid.Column

export default function App() {
  const { isDebug } = useDebug();
  const { isConnected } = useAccount();

  return (
    <DojoSetup>
      <StateProvider>
        <Container text className="CenteredContainer">

          {/* _.⚡★tooL◆ */}
          <Grid>

            <Row columns={'equal'}>
              <Col>
                <Divider />
              </Col>
            </Row>

            <Row columns={'equal'}>
              <Col textAlign="left" verticalAlign="bottom">
                <h1>LS RENDERER</h1>
              </Col>
              <Col textAlign="right" verticalAlign="top">
                <ConnectedHeader />
                {!isConnected && <ConnectButton />}
              </Col>
            </Row>

            <Row columns={'equal'}>
              <Col>
                <Divider />
              </Col>
            </Row>

            <Row columns={1} className="NoPadding NoMargin NoBorder">
              <Col>
                <Main />
              </Col>
            </Row>

            <Row columns={'equal'}>
              <Col>
                <Divider />
              </Col>
            </Row>

            <Row columns={'equal'}>
              <Col>
                custom renderer for <a href='https://lootsurvivor.io'>Loot Survivor</a>
                <br />
                <a href='https://x.com/matalecode'>@matalecode</a> / <a href='https://github.com/rsodre/ls-renderrer'>github</a>
              </Col>
            </Row>

          </Grid>

        </Container >
      </StateProvider>
    </DojoSetup>
  );
}
