package keeper

import (
	"fmt"

	"github.com/Stride-Labs/stride/x/stakeibc/types"

	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
	channeltypes "github.com/cosmos/ibc-go/v3/modules/core/04-channel/types"
	"github.com/golang/protobuf/proto"
)

func (k Keeper) MarshalClaimCallbackArgs(ctx sdk.Context, claimCallback types.ClaimCallback) ([]byte, error) {
	out, err := proto.Marshal(&claimCallback)
	if err != nil {
		k.Logger(ctx).Error(fmt.Sprintf("MarshalClaimCallbackArgs %v", err.Error()))
		return nil, err
	}
	return out, nil
}

func (k Keeper) UnmarshalClaimCallbackArgs(ctx sdk.Context, claimCallback []byte) (*types.ClaimCallback, error) {
	unmarshalledDelegateCallback := types.ClaimCallback{}
	if err := proto.Unmarshal(claimCallback, &unmarshalledDelegateCallback); err != nil {
        k.Logger(ctx).Error(fmt.Sprintf("UnmarshalClaimCallbackArgs %v", err.Error()))
		return nil, err
	}
	return &unmarshalledDelegateCallback, nil
}

func ClaimCallback(k Keeper, ctx sdk.Context, packet channeltypes.Packet, ack *channeltypes.Acknowledgement_Result, args []byte) error {
	k.Logger(ctx).Info("ClaimCallback executing", "packet", packet, "ack", ack, "args", args)
	// deserialize the args
	claimCallback, err := k.UnmarshalClaimCallbackArgs(ctx, args)
	if err != nil {
		return err
	}
	k.Logger(ctx).Info(fmt.Sprintf("ClaimCallback %v", claimCallback))
	userClaimRecord, found := k.RecordsKeeper.GetUserRedemptionRecord(ctx, claimCallback.GetUserRedemptionRecordId())
	if !found {
		return sdkerrors.Wrapf(types.ErrRecordNotFound, "user redemption record not found %s", claimCallback.GetUserRedemptionRecordId())
	}

	if ack == nil {
		// transaction on the host chain failed
		// set UserClaimRecord as claimable
		userClaimRecord.IsClaimable = true
		k.RecordsKeeper.SetUserRedemptionRecord(ctx, userClaimRecord)
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidRequest, "ack is nil, tx failed on host chain")
	}
	// claim successfully processed
	k.RecordsKeeper.RemoveUserRedemptionRecord(ctx, claimCallback.GetUserRedemptionRecordId())
	return nil
}
