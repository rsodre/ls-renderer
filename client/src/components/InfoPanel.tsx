import { Divider, Grid } from "semantic-ui-react";

const Row = Grid.Row
const Col = Grid.Column

export default function InfoPanel() {
  return (
    <Grid>
      <Row columns={'equal'}>
        <Col>
          <p>
            <b>SKULLER</b> a custom renderer for <a href='https://dojoengine.org'>Loot Survivor</a>
            <br />wrapped with <a href='https://dojoengine.org'>Dojo</a>, a fully on-chaingame engine.
          </p>
          <p>
            It's <b>open source</b>, like Loot Survivor
            <br />Go to <a href='https://github.com/rsodre/skuller'>github</a> for more info.
          </p>
        </Col>
      </Row>
    </Grid>
  );
}
