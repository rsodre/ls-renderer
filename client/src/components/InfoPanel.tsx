import { Divider, Grid } from "semantic-ui-react";

const Row = Grid.Row
const Col = Grid.Column

export default function InfoPanel() {
  return (
    <>
      <Divider />
      <Grid>
        <Row columns={'equal'}>
          <Col>
            <p>
              This is a custom renderer for <a href='https://dojoengine.org'>Loot Survivor</a>
              <br />made with <a href='https://dojoengine.org'>Dojo</a>, a game engine for Starknet.
              </p>
            <p>
              
              It's <a href='https://github.com/rsodre/ls-renderrer'>open-source</a>, like Loot Survivor.
              <br />Go there for more info.
            </p>
          </Col>
        </Row>
      </Grid>
    </>
  );
}
