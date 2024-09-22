import { useMemo } from "react";
import { Grid, Icon, Image, SemanticWIDTHS } from "semantic-ui-react";
import { BigNumberish } from "starknet";
import { useTokenUri } from "../hooks/useTokenUri";
import { goToTokenPage } from "../utils/navigation";
import { useStateContext } from "../hooks/StateContext";
import { Adventurer } from "../loot-survivor/types";

const Row = Grid.Row
const Col = Grid.Column

export default function TokenGrid({
  adventurers,
  skip,
}: {
  adventurers: Adventurer[]
  skip: number
}) {
  const { gridSize, gridWidth, gridHeight } = useStateContext();

  let columns = useMemo(() => {
    let result = []
    for (let i = 0; i < adventurers.length; i++) {
      const adventurer = adventurers[i]
      if (adventurer) {
        const tokenId = adventurer.id ?? 0
        const name = adventurer.name ?? '?'
        result.push(
          <Col key={`${tokenId}`} textAlign='center'>
            <TokenImage tokenId={tokenId} name={name} />
          </Col>
        )
      }
    }
    return result
  }, [adventurers, skip, gridSize])

  return (
    <Grid>
      <Row columns={gridWidth as SemanticWIDTHS}>
        {columns}
      </Row>
    </Grid>
  );
}

function TokenImage({
  tokenId,
  name,
}: {
  tokenId: BigNumberish
  name: string
}) {
  const { image, isLoading } = useTokenUri(tokenId);
  const classNames = useMemo(() => {
    const classes = ['Padded']
    if (!isLoading) classes.push('Anchor')
    return classes.join(' ')
  }, [isLoading])

  const _click = () => {
    if (!isLoading && image) {
      goToTokenPage(Number(tokenId));
    }
  }
  return (
    <div>
      <Image src={image ?? '/images/placeholder.svg'} fluid centered spaced className={classNames} onClick={_click} />
      {isLoading &&
        <div className="PlaceholderOverlay">
          <Icon name='spinner' loading size='large' />
        </div>
      }
      {name}
      {/* <div className="PlaceholderOverlayId">
        {`#${tokenId}`}
      </div> */}
    </div>
  );
}
