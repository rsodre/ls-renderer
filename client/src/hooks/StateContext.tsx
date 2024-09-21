import { useAccount } from '@starknet-react/core'
import React, { ReactNode, createContext, useReducer, useContext, useEffect, useMemo } from 'react'
import { Network } from '../loot-survivor'

//--------------------------------
// State
//

export enum TokenSet {
  Collected = 'Collected',
  All = 'Search',
  Info = 'Info',
}

export const initialState = {
  gridSize: 6,
  gridWidth: 3,
  gridHeight: 2,
  tokenSet: TokenSet.Info,
  pageIndex: 0,
  tokenId: 0,
  gridMode: true,
  network: 'mainnet' as Network,
}

enum StateContextActions {
  SET_TOKEN_SET = 'SET_TOKEN_SET',
  SET_PAGE_INDEX = 'SET_PAGE_INDEX',
  SET_TOKEN_ID = 'SET_TOKEN_ID',
}


//--------------------------------
// Types
//
type StateContextStateType = typeof initialState

type ActionType =
  | { type: 'SET_TOKEN_SET', payload: TokenSet }
  | { type: 'SET_PAGE_INDEX', payload: number }
  | { type: 'SET_TOKEN_ID', payload: number }


//--------------------------------
// Context
//
const StateContext = createContext<{
  state: StateContextStateType
  dispatch: React.Dispatch<any>
}>({
  state: initialState,
  dispatch: () => null,
})

//--------------------------------
// Provider
//
interface StateProviderProps {
  children: string | JSX.Element | JSX.Element[] | ReactNode
}
const StateProvider = ({
  children,
}: StateProviderProps) => {
  const [state, dispatch] = useReducer((state: StateContextStateType, action: ActionType) => {
    let newState = { ...state }
    switch (action.type) {
      case StateContextActions.SET_TOKEN_SET: {
        newState.tokenSet = action.payload as TokenSet
        newState.gridMode = true
        break
      }
      case StateContextActions.SET_PAGE_INDEX: {
        newState.pageIndex = action.payload as number
        break
      }
      case StateContextActions.SET_TOKEN_ID: {
        newState.tokenId = action.payload as number
        newState.gridMode = !Boolean(newState.tokenId)
        break
      }
      default:
        console.warn(`StateProvider: Unknown action [${action.type}]`)
        return state
    }
    return newState
  }, initialState)

  return (
    <StateContext.Provider value={{ dispatch, state: {
      ...state,
    } }}>
      {children}
    </StateContext.Provider>
  )
}

export { StateProvider, StateContext, StateContextActions as StateActions }


//--------------------------------
// Hooks
//

export const useStateContext = () => {
  const { state, dispatch } = useContext(StateContext)
  const dispatchSetTokenSet = (newTokenSet: TokenSet) => {
    dispatch({
      type: StateContextActions.SET_TOKEN_SET,
      payload: newTokenSet,
    })
  }
  const dispatchSetPageIndex = (newPageIndex: number) => {
    dispatch({
      type: StateContextActions.SET_PAGE_INDEX,
      payload: newPageIndex,
    })
  }
  const dispatchSetTokenId = (newTokenId: number) => {
    dispatch({
      type: StateContextActions.SET_TOKEN_ID,
      payload: newTokenId,
    })
  }
  return {
    ...state,
    // StateContextActions,
    // dispatch,
    dispatchSetTokenSet,
    dispatchSetPageIndex,
    dispatchSetTokenId,
  }
}



