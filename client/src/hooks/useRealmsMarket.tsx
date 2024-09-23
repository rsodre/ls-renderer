import { useCallback } from 'react'
import { useLootSurvivorGameContractAddress } from "../hooks/useLootSurvivorContract";

//
// from:
// https://github.com/BibliothecaDAO/market/blob/main/apps/arkmarket/src/app/token/%5BcontractAddress%5D/%5BtokenId%5D/components/refresh-metadata-button.tsx
//

// TODO: get the correct url
export const MARKETPLACE_API_URL = 'https://api-orderbook.arkproject.dev'

export const useRealmsMarketRefreshMetadata = ({
  tokenId,
}: {
  tokenId: string;
}) => {
  const { contractAddress } = useLootSurvivorGameContractAddress();

  const refreshMetadata = useCallback(() => {
    const _fetch = async () => {
      const response = await fetch(
        `${MARKETPLACE_API_URL}/metadata/refresh`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            contract_address: contractAddress,
            token_id: tokenId,
          }),
        },
      );
      if (!response.ok) {
        throw new Error("Failed to refresh metadata");
      }
    }
    _fetch();
  }, [])

  return {
    refreshMetadata
  }

}
