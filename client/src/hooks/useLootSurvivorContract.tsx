import { useCallback, useMemo, useState } from "react";
import { BigNumberish } from "starknet";
import { useAccount, useContractRead, useContractWrite } from "@starknet-react/core";
import { useStateContext } from "./StateContext";
import { useSkulllerContractAddress } from "./useSkuller";
import { bigintEquals, bigintToHex, isPositiveBigint } from "../utils/types";
import { networkConfig } from "../loot-survivor/networkConfig";
import GameAbi from "../loot-survivor/abi/Game.json";
import { useMetadataContext } from "./MetadataContext";

export const useLootSurvivorGameContractAddress = () => {
  const { network } = useStateContext();
  const contractAddress = useMemo(() => (networkConfig[network!].gameAddress), [network]);
  return {
    contractAddress: bigintToHex(contractAddress ?? 0),
  }
}

export const useOwnerOf = (token_id: BigNumberish) => {
  const { address } = useAccount()
  const { contractAddress } = useLootSurvivorGameContractAddress();

  const { data, isLoading } = useContractRead({
    abi: GameAbi,
    address: bigintToHex(contractAddress),
    functionName: 'owner_of',
    args: [bigintToHex(token_id)],
    enabled: isPositiveBigint(token_id),
  });

  const owner = useMemo(() => (data ? bigintToHex(data as string) : null), [data]);
  const youOwn = useMemo(() => bigintEquals(owner, address), [owner, address]);

  return {
    owner,
    youOwn,
    isLoading,
  }
}

export const useCurrentRendererContract = (token_id: BigNumberish) => {
  const { contractAddress } = useLootSurvivorGameContractAddress();

  const { data, isLoading } = useContractRead({
    abi: GameAbi,
    address: bigintToHex(contractAddress),
    functionName: 'get_adventurer_renderer',
    args: [bigintToHex(token_id)],
    enabled: isPositiveBigint(token_id),
  });

  const { skullerContractAddress } = useSkulllerContractAddress()

  const rendererContract = useMemo(() => (data ? bigintToHex(data as string) : null), [data]);
  const isSkuller = useMemo(() =>
    bigintEquals(rendererContract, skullerContractAddress
  ), [rendererContract, skullerContractAddress]);

  return {
    rendererContract,
    skullerContractAddress,
    isSkuller,
    isLoading,
  }
}

export const useSetRendererContract = (token_id: BigNumberish) => {
  const { skullerContractAddress } = useSkulllerContractAddress()
  const { contractAddress } = useLootSurvivorGameContractAddress();
  const { dispatchSetUri } = useMetadataContext()

  const [isLoading, setIsLoading] = useState(false)
  
  const { writeAsync } = useContractWrite({
    abis: [GameAbi],
    calls: [{
      contractAddress: bigintToHex(contractAddress),
      entrypoint: 'set_adventurer_renderer',
      calldata: [bigintToHex(token_id), bigintToHex(skullerContractAddress)],
    }],
  });

  const { writeAsync: resetAsync } = useContractWrite({
    abis: [GameAbi],
    calls: [{
      contractAddress: bigintToHex(contractAddress),
      entrypoint: 'set_adventurer_renderer',
      calldata: [bigintToHex(token_id), bigintToHex(0)],
    }],
  });

  const _write = useCallback((reset: boolean) => {
    const _finished = () => {
      setIsLoading(false)
      dispatchSetUri(token_id, null)
    }
    setIsLoading(true)
    if (reset) {
      resetAsync().then(() => _finished())
    } else {
      writeAsync().then(() => _finished())
    }
  }, [writeAsync, resetAsync, contractAddress, token_id, skullerContractAddress])

  return {
    write: _write,
    isLoading,
  }
}
