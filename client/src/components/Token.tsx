import { useMemo } from "react";
import { Grid, Icon, Image } from "semantic-ui-react";
import { useTokenUri } from "../hooks/useTokenUri";
import { AddressShort } from "./ui/AddressShort";
import { useStateContext } from "../hooks/StateContext";
import { useAdventurerById } from "../hooks/useLootSurvivorQuery";
import { BigNumberish } from "starknet";
import { useSkulllerAdventurerTokenUri, useSkulllerSimulateTokenUri } from "../hooks/useSkuller";
import { useCurrentRendererContract, useOwnerOf } from "../hooks/useLootSurvivorContract";

const Row = Grid.Row
const Col = Grid.Column


export function TokenSkuller() {
  const { tokenId } = useStateContext()
  const { name, image, attributes, isLoading } = useSkulllerAdventurerTokenUri(tokenId);
  // const { name, image, attributes, isLoading } = useSkulllerSimulateTokenUri(tokenId);
  return <TokenWithMetadata
    tokenId={tokenId}
    name={name}
    image={image}
    attributes={attributes}
    isLoading={isLoading}
  />
}

export function Token() {
  const { tokenId } = useStateContext()
  const { name, image, attributes, isLoading } = useTokenUri(tokenId);
  const { adventurer } = useAdventurerById(tokenId)
  return <TokenWithMetadata
    tokenId={tokenId}
    name={name}
    image={image}
    attributes={attributes}
    isLoading={isLoading}
  />
}

function TokenWithMetadata({
  tokenId,
  name,
  image,
  attributes,
  isLoading,
}: {
  tokenId: BigNumberish
  name: string
  image: string
  attributes: Record<string, string>
  isLoading: boolean
}) {
  const { owner } = useOwnerOf(tokenId)
  const { rendererContract } = useCurrentRendererContract(tokenId)
  console.log('rendererContract', rendererContract)
  
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

      {/* <Row columns={'equal'}>
        <Col>
          <Image src={image ?? '/images/placeholder.svg'} size='big' centered spaced />
        </Col>
        <Col>
          <Image src={image ?? '/images/placeholder.svg'} size='big' centered spaced />
        </Col>
      </Row> */}

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
