/*
  Copyright 2019-2023 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "./IERC20.sol";

/**
  Interface for the optional metadata functions from the ERC20 standard.
*/
interface IERC20Metadata is IERC20 {
    /**
      Returns the name of the token.
    */
    function name() external view returns (string memory);

    /**
      Returns the symbol of the token.
    */
    function symbol() external view returns (string memory);

    /**
      Returns the decimals places of the token.
    */
    function decimals() external view returns (uint8);
}