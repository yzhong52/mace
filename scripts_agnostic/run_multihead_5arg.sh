#!/bin/bash
DATA_DIR=/lustre/fsn1/projects/rech/gax/unh55hx/data/multihead_dataset
module load pytorch-gpu/py3/2.3.1
export PATH="$PATH:/linkhome/rech/genrre01/unh55hx/.local/bin"
REAL_BATCH_SIZE=$(($1 * $3))
CONF=$4
R=$5
NUM_CHANNEL=$6
NUM_RADIAL=$7
MLP_IRREPS=$8
SEED=$9
ROOT_DIR=/lustre/fsn1/projects/rech/gax/unh55hx/mace_multi_head_interface
conf_str="${CONF%.yaml}"
stress=${10}
cd $ROOT_DIR
mace_run_train \
    --name="MACE_medium_stress${stress}_nc${NUM_CHANNEL}_nr${NUM_RADIAL}_MLP${MLP_IRREPS}_agnesi_b${REAL_BATCH_SIZE}_lr$2_${conf_str}_agnostic_rm_int_con_firstlayer" \
    --loss='universal' \
    --energy_weight=1 \
    --forces_weight=10 \
    --compute_stress=True \
    --stress_weight=${stress} \
    --eval_interval=1 \
    --error_table='PerAtomMAE' \
    --model="MACE" \
    --interaction_first="RealAgnosticInteractionBlock" \
    --interaction="RealAgnosticResidualInteractionBlock" \
    --num_interactions=2 \
    --correlation=3 \
    --max_ell=3 \
    --r_max=${R} \
    --max_L=1 \
    --num_channels=${NUM_CHANNEL} \
    --num_radial_basis=${NUM_RADIAL} \
    --MLP_irreps=${MLP_IRREPS} \
    --scaling='rms_forces_scaling' \
    --lr=$2 \
    --weight_decay=1e-8 \
    --ema \
    --ema_decay=0.995 \
    --scheduler_patience=5 \
    --batch_size=$1 \
    --valid_batch_size=32 \
    --pair_repulsion \
    --distance_transform="Agnesi" \
    --max_num_epochs=100 \
    --patience=40 \
    --amsgrad \
    --seed=${SEED} \
    --clip_grad=100 \
    --keep_checkpoints \
    --restart_latest \
    --save_cpu \
    --config="multihead_config/${CONF}" \
    --device=cuda \
    --num_workers=8 \
    --distributed \
    --agnostic_int True False \
    --agnostic_con True False \

# --name="MACE_medium_agnesi_b32_origin_mponly" \
