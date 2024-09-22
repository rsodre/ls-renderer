import { useMemo, useState } from "react";
import { Grid, Button, Divider, Input } from "semantic-ui-react";
import { MetadataProvider } from "../hooks/MetadataContext";
import { useAccount } from "@starknet-react/core";
import { useTokenIdFromUrl } from "../hooks/useTokenIdFromUrl";
import { useAdventurersByOwner, useAdventurersByOwnerCount } from "../hooks/useLootSurvivorQuery";
import { TokenSet, useStateContext } from "../hooks/StateContext";
import { goToTokenPage } from "../utils/navigation";
import { Token, TokenSkuller } from "./Token";
import Navigation from "./Navigation";
import TokenGrid from "./TokenGrid";
import InfoPanel from "./InfoPanel";
import { bigintEquals } from "../utils/types";
import { useCurrentRendererContract, useOwnerOf } from "../hooks/useLootSurvivorContract";
import { ConnectButton } from "./Connect";

const Row = Grid.Row
const Col = Grid.Column

export default function Main() {
  // this hook will keep StateContext in sync with the URL
  useTokenIdFromUrl()

  const { isConnected, address } = useAccount();
  const { gridMode, tokenSet, dispatchSetTokenSet } = useStateContext();

  const { adventurersByOwnerCount } = useAdventurersByOwnerCount(address ?? 0);

  const _changedTab = (newTokenSet: TokenSet) => {
    dispatchSetTokenSet(newTokenSet)
    goToTokenPage(0);
  }

  return (
    <MetadataProvider>
      <Grid>
        <Row columns={'equal'}>
          <Col>
            <Button fluid secondary toggle active={tokenSet == TokenSet.Collected} onClick={() => _changedTab(TokenSet.Collected)}>
              {`Collected (${adventurersByOwnerCount})`}
            </Button>
          </Col>
          <Col>
            <Button fluid secondary toggle active={tokenSet == TokenSet.Search} disabled={!isConnected} onClick={() => _changedTab(TokenSet.Search)}>
              {`Search`}
            </Button>
          </Col>
          <Col>
            <Button fluid secondary toggle active={tokenSet == TokenSet.Info} onClick={() => _changedTab(TokenSet.Info)}>
              {`Info`}
            </Button>
          </Col>
        </Row>
        <Row>
          <Col>
            <Divider />
          </Col>
        </Row>
        <Row columns={'equal'}>
          <Col>
            {tokenSet == TokenSet.Info ? <InfoPanel />
              : tokenSet == TokenSet.Search ? <SearchTab />
                : <>
                  {gridMode && <MultiTokenTab tokenCount={adventurersByOwnerCount} />}
                  {!gridMode && <SingleTokenTab />}
                </>
            }
          </Col>
        </Row>
      </Grid>
    </MetadataProvider>
  );
}

//-------------------
// GRID
//
function MultiTokenTab({
  tokenCount,
}: {
  tokenCount: number
}) {
  const { isConnected, address } = useAccount();
  const { gridSize, pageIndex, dispatchSetPageIndex } = useStateContext();
  const { adventurers } = useAdventurersByOwner(address ?? 0, pageIndex, true)

  const pageCount = useMemo(() => Math.ceil(tokenCount / gridSize), [tokenCount, gridSize])
  const skip = useMemo(() => (pageIndex * gridSize), [pageIndex, gridSize])

  const _changePage = (newPageIndex: number) => {
    dispatchSetPageIndex(newPageIndex);
  }

  if (!isConnected) {
    return (
      <>
        <p>connect your wallet to<br />manage your collection</p>
        <ConnectButton />
      </>
    )
  }

  return (
    <>
      <TokenGrid
        adventurers={adventurers}
        skip={skip}
      />
      <Navigation
        pageCount={pageCount}
        pageIndex={pageIndex}
        onPageChange={_changePage}
        prefix='Page'
      />
    </>
  );
}


//-------------------
// TOKEN
//
function SingleTokenTab() {
  const { tokenId } = useStateContext()
  const { youOwn } = useOwnerOf(tokenId)
  const { rendererContract, isSkuller } = useCurrentRendererContract(tokenId)
  const [simulated, setSimulated] = useState(false)
  return (
    <>
      <Grid>
        <Row columns={'equal'}>
          <Col>
            <Button fluid secondary toggle active={!simulated} onClick={() => setSimulated(false)}>
              {`Current`}
            </Button>
          </Col>
          <Col>
            <Button fluid secondary toggle active={simulated} onClick={() => setSimulated(true)}>
              {`SKULLER`}
            </Button>
          </Col>
          <Col>
            {!isSkuller &&
              <Button fluid disabled={!youOwn} onClick={() => setSimulated(true)}>
                {`SET SKULLER`}
              </Button>
            }
            {isSkuller &&
              <Button fluid disabled={!youOwn} onClick={() => setSimulated(true)}>
                {`RESTORE DEFAULT`}
              </Button>
            }
          </Col>
        </Row>
      </Grid>

      {!simulated && <Token />}
      {simulated && <TokenSkuller />}
    </>
  );
}


//-------------------
// SEARCH
//
function SearchTab() {
  const [searchId, setSearchId] = useState(1)
  const canSearch = useMemo(() => (!isNaN(searchId) && searchId > 0), [searchId])

  const _search = () => {
    if (canSearch) {
      goToTokenPage(searchId);
    }
  }

  return (
    <>
      <Grid>
        <Row columns={'equal'}>
          <Col verticalAlign={'middle'} textAlign={'center'}>
            <b>Adventurer ID:</b>
          </Col>
          <Col>
            <Input fluid placeholder='Search...' onChange={(e) => setSearchId(Number(e.target.value))} />
          </Col>
          <Col>
            <Button fluid disabled={!canSearch} onClick={() => _search()}>
              {`GO`}
            </Button>
          </Col>
        </Row>
      </Grid>

      <SingleTokenTab />
    </>
  )
}

