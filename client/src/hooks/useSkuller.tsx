import { useEffect, useMemo, useState } from "react";
import { BigNumberish } from "starknet";
import { getContractByName } from "@dojoengine/core";
import { useDojo } from "../dojo/useDojo"
import { useUriToMetadata } from "./useTokenUri";
import { token_uri_params } from "../loot-survivor";
import { Adventurer } from "../loot-survivor/types";

export const useSkulllerContractAddress = () => {
  const { setup: { manifest } } = useDojo();
  const { address: skullerContractAddress } = useMemo(() => getContractByName(manifest, 'skuller', 'main'), [manifest]);
  return {
    skullerContractAddress
  }
}

export const useSkulllerAdventurerTokenUri = (token_id: BigNumberish) => {
  const {
    setup: {
      systemCalls: { adventurer_token_uri },
    },
  } = useDojo();

  const [uri, setUri] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const _fetch = () => {
    if (token_id) {
      // console.log(`>>>> fetching token uri for ${token_id}`)
      setUri('')
      setIsLoading(true)
      adventurer_token_uri(token_id).then((v) => {
        setUri(v ?? '')
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
    _fetch();
  }, [token_id])

  const metadata = useUriToMetadata(token_id, uri)

  return {
    // token_uri: _fetch
    ...metadata,
    isLoading,
  }
}


export const useSkulllerSimulateTokenUri = (token_id: BigNumberish) => {
  const {
    setup: {
      systemCalls: { simulate_token_uri },
    },
  } = useDojo();

  const [uri, setUri] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const _fetch = () => {
    if (token_id) {
      // console.log(`>>>> fetching token uri for ${token_id}`)
      setUri('')
      setIsLoading(true)
      simulate_token_uri(token_id).then((v) => {
        setUri(v ?? '')
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
    _fetch();
  }, [token_id])

  const metadata = useUriToMetadata(token_id, uri)

  return {
    // token_uri: _fetch
    ...metadata,
    isLoading,
  }
}


//
// TODO
// INCREADIBLY HARD TO SIMILATE THIS!
//
export const useSkulllerTokenUri = (token_id: BigNumberish, adventurer: Adventurer) => {
  const {
    setup: {
      systemCalls: { token_uri },
    },
  } = useDojo();

  const params = useMemo(() => {
    // if (!adventurer) return null
    const result: token_uri_params = {} as token_uri_params
    return result
  }, [token_id, adventurer])

  const [uri, setUri] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const _fetch = () => {
    if (token_id) {
      // console.log(`>>>> fetching token uri for ${token_id}`)
      setUri('')
      setIsLoading(true)
      token_uri(params).then((v) => {
        setUri(v ?? '')
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
    _fetch();
  }, [token_id])

  const metadata = useUriToMetadata(token_id, uri)

  return {
    // token_uri: _fetch
    ...metadata,
    isLoading,
  }
}
