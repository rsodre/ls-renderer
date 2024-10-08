import { useMemo } from "react";
import { Grid, Icon, Image } from "semantic-ui-react";
import { useTokenUri } from "../hooks/useTokenUri";
import { AddressShort } from "./ui/AddressShort";
import { useStateContext } from "../hooks/StateContext";
import { useAdventurerById } from "../hooks/useLootSurvivorQuery";
import { BigNumberish } from "starknet";
import { useSkulllerAdventurerTokenUri, useSkulllerSimulateTokenUri } from "../hooks/useSkuller";
import { useCurrentRendererContract, useOwnerOf } from "../hooks/useLootSurvivorContract";
import { goToTokenPage, useRealmsWorldUrl } from "../utils/navigation";

const Row = Grid.Row
const Col = Grid.Column


export function TokenSkuller() {
  const { tokenId } = useStateContext()

  // to test on localhost...
  // - deploy to local katana, torri not required
  // - edit .env: VITE_PUBLIC_CHAIN_ID=KATANA_LOCAL
  // - uncomment useSkulllerSimulateTokenUri()
  // - comment useSkulllerAdventurerTokenUri()
  // const { name, image, attributes, isLoading } = useSkulllerSimulateTokenUri(tokenId);
  const { name, image, attributes, isLoading } = useSkulllerAdventurerTokenUri(tokenId);

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
  const { realmsWorldUrl } = useRealmsWorldUrl(tokenId)
  
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
          <h4 className='White'>{name}</h4>
          <a href={realmsWorldUrl}>Realms.world</a>
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
