import { useMemo } from "react"
import { BigNumberish } from "starknet";
import { useStateContext } from "./StateContext";
import { bigintToHex, isPositiveBigint } from "../utils/types";
import useCustomQuery from "../loot-survivor/useCustomQuery";
import {
  getAdventurersByOwnerCount,
  getAliveAdventurersCount,
  getAdventurersByOwner,
  getAdventurerById,
} from "../loot-survivor/queries";
import {
  Adventurer,
} from "../loot-survivor/types";

export function useAdventurersByOwnerCount(owner: BigNumberish) {
  const { network } = useStateContext()
  const variables = useMemo(() => ({
    owner: bigintToHex(owner).toLowerCase(),
  }), [owner]);
  const data = useCustomQuery(
    network,
    getAdventurersByOwnerCount,
    variables,
    !isPositiveBigint(owner)
  );
  return {
    adventurersByOwnerCount: data?.countTotalAdventurers as number ?? 0
  }
}

export function useAliveAdventurersByOwnerCount(owner: BigNumberish) {
  const { network } = useStateContext()
  const variables = useMemo(() => ({
    owner: bigintToHex(owner).toLowerCase(),
  }), [owner]);
  const data = useCustomQuery(
    network,
    getAliveAdventurersCount,
    variables,
    !isPositiveBigint(owner)
  );
  return {
    aliveAdventurersByOwnerCount: data?.countAliveAdventurers as number ?? 0
  }
}

export function useAdventurersByOwner(owner: BigNumberish, pageIndex: number, showZeroHealth: boolean = true) {
  const { network, gridSize } = useStateContext()
  const variables = useMemo(() => ({
    owner: bigintToHex(owner).toLowerCase(),
    health: showZeroHealth ? 0 : 1,
    skip: (pageIndex * gridSize),
  }), [owner, showZeroHealth, pageIndex, gridSize]);
  const data = useCustomQuery(
    network,
    getAdventurersByOwner,
    variables,
    !isPositiveBigint(owner)
  );
  return {
    adventurers: (data?.adventurers as Adventurer[] ?? []).slice(0, gridSize),
  }
}

export function useAdventurerById(tokenId: number) {
  const { network } = useStateContext()
  const variables = useMemo(() => ({
    id: tokenId,
  }), [tokenId]);
  const data = useCustomQuery(
    network,
    getAdventurerById,
    variables,
    (tokenId > 0)
  );
  // console.log(`ADVENTURER DATA:`, variables, data)
  return {
    adventurer: data?.adventurer as Adventurer ?? null,
  }
}




