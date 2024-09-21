import { useMemo } from "react";
import { Grid, Icon, Image } from "semantic-ui-react";
import { useTokenUri } from "../hooks/useTokenUri";
import { AddressShort } from "./ui/AddressShort";
import { useStateContext } from "../hooks/StateContext";
import { useAdventurerById } from "../hooks/useLootSurvivorQuery";
import { BigNumberish } from "starknet";
import { useSkulllerASimulateTokenUri } from "../hooks/useSkuller";

const Row = Grid.Row
const Col = Grid.Column


export function TokenSkuller() {
  const { tokenId } = useStateContext()
  const { adventurer } = useAdventurerById(tokenId)
  // const { name, image, attributes, isLoading } = useSkulllerAdventurerTokenUri(tokenId);
  const { name, image, attributes, isLoading } = useSkulllerASimulateTokenUri(tokenId);
  return <TokenWithMetadata
    name={name}
    image={image}
    attributes={attributes}
    isLoading={isLoading}
    owner={adventurer?.owner ?? 0}
  />
}

export function Token() {
  const { tokenId } = useStateContext()
  const { name, image, attributes, isLoading } = useTokenUri(tokenId);
  const { adventurer } = useAdventurerById(tokenId)
  return <TokenWithMetadata
    name={name}
    image={image}
    attributes={attributes}
    isLoading={isLoading}
    owner={adventurer?.owner ?? 0}
  />
}

function TokenWithMetadata({
  name,
  image,
  attributes,
  isLoading,
  owner,
}: {
  name: string
  image: string
  attributes: Record<string, string>
  isLoading: boolean
  owner: BigNumberish
}) {
  let attributesRows = useMemo(() => Object.keys(attributes ?? {}).map(key => (
    <Row key={key} columns={'equal'} className="AttributeRow">
      <Col textAlign="left">
        {key}
      </Col>
      <Col textAlign="right">
        {attributes[key]}
      </Col>
    </Row>
  )), [attributes, isLoading])

  return (
    <Grid>
      <Row columns={'equal'}>
        <Col>
          <Image src={image ?? '/images/placeholder.svg'} size='big' centered spaced />
          {!image &&
            <div className="PlaceholderOverlay">
              <Icon name='spinner' loading size='big' />
            </div>
          }
        </Col>
      </Row>

      <Row columns={'equal'} className="AttributeRow">
        <Col textAlign="center">
          <h4>{name}</h4>
        </Col>
      </Row>

      {attributesRows}

      <Row columns={'equal'} className="AttributeRow">
        <Col textAlign="left">
          Owner
        </Col>
        <Col textAlign="right">
          {isLoading ? '...' : <AddressShort address={owner ?? 0} />}
        </Col>
      </Row>

    </Grid>
  );
}
