package stakeibc_test

import (
	"testing"

	keepertest "github.com/Stride-Labs/stride/testutil/keeper"
	"github.com/Stride-Labs/stride/testutil/nullify"
	"github.com/Stride-Labs/stride/x/stakeibc"
	"github.com/Stride-Labs/stride/x/stakeibc/types"
	"github.com/stretchr/testify/require"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),
		PortId: types.PortID,
		ICAAccount: &types.ICAAccount{
			Address: "78",
		},
		HostZoneList: []types.HostZone{
			{
				ChainId: "0",
			},
			{
				ChainId: "1",
			},
		},
		HostZoneCount: 2,
		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.StakeibcKeeper(t)
	stakeibc.InitGenesis(ctx, *k, genesisState)
	got := stakeibc.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	require.Equal(t, genesisState.PortId, got.PortId)

	require.Equal(t, genesisState.ICAAccount, got.ICAAccount)
	require.ElementsMatch(t, genesisState.HostZoneList, got.HostZoneList)
	require.Equal(t, genesisState.HostZoneCount, got.HostZoneCount)
	// this line is used by starport scaffolding # genesis/test/assert
}
