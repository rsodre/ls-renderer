import { useEffect, useMemo, useState } from "react"
import { getContractByName } from "@dojoengine/core"
import { useComponentValue } from "@dojoengine/react"
import { useDojo } from "../dojo/useDojo"
import { bigintToEntity } from "../utils/types"

export const useTokenContract = () => {
  const { setup: { clientComponents } } = useDojo();
  const [contractAddress, setContractAddress] = useState<string>('')

  const { setup: { manifest } } = useDojo()
  useEffect(() => {
    const contract = getContractByName(manifest, 'karat', 'karat_token');
    setContractAddress(contract?.address ?? '')
  }, [])

  const contractEntityId = useMemo(() => bigintToEntity(contractAddress), [contractAddress])

  return {
    contractAddress,
    contractEntityId,
    components: clientComponents,
  }
}

type useConfigResult = {
  minterAddress: bigint
  rendererAddress: bigint
  maxSupply: number
  availableSupply: number
  isCoolDown: boolean
  isPending: boolean
}
export const useConfig = (): useConfigResult => {
  const { setup: { clientComponents: { Config } } } = useDojo();
  const { contractEntityId } = useTokenContract()
  const data: any = useComponentValue(Config, contractEntityId);
  return {
    minterAddress: BigInt(data?.minter_address ?? 0),
    rendererAddress: BigInt(data?.renderer_address ?? 0),
    maxSupply: Number(data?.max_supply ?? 0),
    availableSupply: Number(data?.available_supply ?? 0),
    isCoolDown: Boolean(data?.cool_down ?? false),
    isPending: (data == null),
  }
}

