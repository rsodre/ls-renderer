import { AccountInterface, BigNumberish } from "starknet";
import { ContractComponents } from "./generated/contractComponents";
import { ClientComponents } from "./createClientComponents";
import type { IWorld } from "./generated/setupWorld";
import { token_uri_params } from "../loot-survivor";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { client }: { client: IWorld },
  contractComponents: ContractComponents,
  { Config }: ClientComponents
) {
  const token_uri = async (params: token_uri_params): Promise<string | null> => {
    try {
      const uri = await client.skuller.token_uri(params);
      return uri as string ?? null
    } catch (e) {
      console.error(`>>> token_uri ERROR:`, e);
      return null
    }
  };

  const adventurer_token_uri = async (token_id: BigNumberish): Promise<string | null> => {
    try {
      const uri = await client.skuller.adventurer_token_uri(token_id);
      return uri as string ?? null
    } catch (e) {
      console.error(`>>> adventurer_token_uri ERROR:`, e);
      return null
    }
  };

  const simulate_token_uri = async (token_id: BigNumberish): Promise<string | null> => {
    try {
      const uri = await client.skuller.simulate_token_uri(token_id);
      return uri as string ?? null
    } catch (e) {
      console.error(`>>> simulate_token_uri ERROR:`, e);
      return null
    }
  };

  return {
    token_uri,
    adventurer_token_uri,
    simulate_token_uri,
  };
}
