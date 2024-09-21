import { useEffect, useMemo, useState } from "react";
import { BigNumberish } from "starknet";
import { useDojo } from "../dojo/useDojo"
import { useTokenContract } from "./useToken";
import { useMetadataContext, useTokenUriContext } from "./MetadataContext";
import { useUriToMetadata } from "./useTokenUri";

export const useRendererTokenUri = (token_id: BigNumberish) => {
  const {
    setup: {
      systemCalls: { token_uri },
    },
  } = useDojo();

  const { contractAddress } = useTokenContract();

  const { dispatchSetUri } = useMetadataContext()
  const cached_uri = useTokenUriContext(token_id)

  const [uri, setUri] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const _fetch = () => {
    if (contractAddress && token_id) {
      // console.log(`>>>> fetching token uri for ${token_id}`)
      setUri('')
      setIsLoading(true)
      token_uri(token_id).then((v) => {
        setUri(v ?? '')
        dispatchSetUri(token_id, v ?? '')
        setIsLoading(false)
      }).catch((e) => {
        console.error(`useTokenUri() ERROR:`, e)
        setIsLoading(false)
      });
    } else {
      return null
    }
  }

  useEffect(() => {
    if (cached_uri) {
      setUri(cached_uri)
    } else {
      _fetch();
    }
  }, [contractAddress, token_id, cached_uri])

  const metadata = useUriToMetadata(token_id, uri)

  return {
    // token_uri: _fetch
    ...metadata,
    isLoading,
  }
}
