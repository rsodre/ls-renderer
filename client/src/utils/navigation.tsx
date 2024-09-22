import { useMemo } from "react";
import { BigNumberish } from "starknet";
import { useLootSurvivorGameContractAddress } from "../hooks/useLootSurvivorContract";

export const goToTokenPage = (token_id: BigNumberish) => {
  const url = token_id ? `#${token_id}` : '';
  window.location.hash = url
}

export const useRealmsWorldUrl = (token_id: BigNumberish) => {
  const { contractAddress } = useLootSurvivorGameContractAddress();
  const realmsWorldUrl = useMemo(() => (
    `https://market.realms.world/token/${contractAddress}/${token_id}`
  ), [contractAddress, token_id]);
  return {
    realmsWorldUrl,
  }
}
