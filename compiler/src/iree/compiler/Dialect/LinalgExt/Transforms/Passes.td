// Copyright 2021 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#ifndef IREE_DIALECT_LINALGEXT_PASSES
#define IREE_DIALECT_LINALGEXT_PASSES

include "mlir/Pass/PassBase.td"

def LinalgExtToLoopsPass :
    InterfacePass<"iree-linalg-ext-to-loops", "mlir::FunctionOpInterface"> {
  let summary = "Convert LinalgExt ops to loops and Linalg ops.";
}

def PadContractionToBlockSizePass :
    Pass<"iree-linalg-pad-contraction-to-block-size", ""> {
  let summary = "Pads contraction (matmul) ops to next multiple of block size";
  let description = [{
    This pass will apply padding to any supported linalg contractions:
      * Row-major matmul:
          Padded to <rowAlignment x columnAlignment>

    Both rowAlignment and columnAlignment must be power-of-two values. If an
    op is already statically padded properly, no change will be made. However,
    if dynamic dimensions exist, padding will be applied regardless. Because
    of the dynamic case, applying this pass multiple times can result in
    mutation on each run.
  }];
  let options = [
    Option<"rowAlignment", "rowAlignment", "int", /*default=*/"16",
           "The row-wise output block size">,
    Option<"columnAlignment", "columnAlignment", "int", /*default=*/"16",
           "The column-wise output block size">,
  ];
}

def TopkSplitReductionPass:
    InterfacePass<"iree-linalg-ext-topk-split-reduction", "mlir::FunctionOpInterface"> {
  let summary = "Topk split reduction pass.";
  let description = [{
    Produces a "map-reduce" style of parallelizing a Topk Op. The op is split
    into two, on containing reducitons in parallel and the other contianing the
    combination of the parallel reductions into a final result.
  }];
  let options = [
    ListOption<"splitRatios", "split-ratios", "int",
           "List of split reduction ratios">,
  ];
}

def DecomposeIm2colPass :
    InterfacePass<"iree-linalg-ext-decompose-im2col", "mlir::FunctionOpInterface"> {
  let summary =
      "Decomposes im2col ops into insert and extract slice ops";
  let options = [
    Option<"unroll", "unroll", "bool", /*default=*/"true",
           "Unroll the resulting loop nest after decomposition.">,
  ];
}

def DecomposeWinogradTransformPass :
    InterfacePass<"iree-linalg-ext-decompose-winograd", "mlir::FunctionOpInterface"> {
  let summary =
      "Decomposes winograd transform ops into linalg ops";
}

def ConvertConvToIm2ColOpPass :
    InterfacePass<"iree-linalg-ext-convert-conv-to-im2col-op", "mlir::FunctionOpInterface"> {
  let summary = "Convert linalg convolution ops to im2col gemm based implementation.";
}

def ConvertConv2DToWinogradPass :
    InterfacePass<"iree-linalg-ext-convert-conv2d-to-winograd", "mlir::FunctionOpInterface"> {
  let summary = "Convert linalg convolution ops to winograd based implementation. By default, "
                "only convs annotated with a `__winograd_conv` attribute will be rewritten.";
  let options = [
    Option<"replaceAllConvs", "replace-all-convs", "bool",
           /*default=*/"false",
           "Choose to ignore `__winograd_conv` annotations and transform all"
           "compatible convolutions.">,
  ];
}

def DecomposeAttentionPass :
    InterfacePass<"iree-linalg-ext-decompose-attention", "mlir::FunctionOpInterface"> {
  let summary =
      "Decomposes attention op into a sequence of linalg ops";
}

def ConvertAttentionToOnlineAttentionPass :
    Pass<"iree-linalg-ext-convert-attention-to-online-attention", ""> {
  let summary = "Converts attention op to online_attention op";
}

def FoldUnitExtentDimsPass :
      Pass<"iree-linalg-ext-fold-unit-extent-dims", "">  {
  let summary = "Folds unit dims for iree_linalg_ext ops";
  let options = [
    Option<"useReshapes", "use-reshapes", "bool", /*default=*/"true",
           "Use reshapes vs slices for rank reduction">,
  ];
  let dependentDialects = [
    "::mlir::tensor::TensorDialect",
    "::mlir::iree_compiler::IREE::LinalgExt::IREELinalgExtDialect"
  ];
}

def TestReshapeFusionPass :
    Pass<"iree-linalg-ext-test-reshape-fusion", ""> {
  let summary = "Test reshape fusion patterns";
}

def VectorizeIREELinalgExtOpsPass :
    InterfacePass<"iree-linalg-ext-vectorize-ops", "mlir::FunctionOpInterface"> {
  let summary = "Convert linalg_ext ops into their vector form.";
  let dependentDialects = [
    "::mlir::vector::VectorDialect",
    "::mlir::arith::ArithDialect"
  ];
}

#endif  // IREE_DIALECT_LINALGEXT_PASSES
