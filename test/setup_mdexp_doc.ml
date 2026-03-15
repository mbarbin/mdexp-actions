(*********************************************************************************)
(*  mdexp-actions - Reusable GitHub Actions for the mdexp tool                   *)
(*  SPDX-FileCopyrightText: 2026 Mathieu Barbin <mathieu.barbin@gmail.com>       *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

(* @mdexp

# mdexp-actions Test

This file demonstrates the use of mdexp with print-table to generate
documentation tables that stay in sync with the code.

## GitHub Actions Status

A table showing the actions available in this repository: *)

module Action = struct
  type t = Setup_mdexp

  let all = [ Setup_mdexp ]
end

let%expect_test "actions table" =
  let open Print_table.O in
  let columns : Action.t Column.t list =
    [ Column.make ~header:"Action" (fun (action : Action.t) ->
        let name =
          match action with
          | Setup_mdexp -> "setup-mdexp"
        in
        Cell.text name)
    ; Column.make ~header:"Description" (fun (action : Action.t) ->
        let description =
          match action with
          | Setup_mdexp -> "Download and install mdexp from GitHub releases"
        in
        Cell.text description)
    ; Column.make ~header:"Status" ~align:Center (fun (action : Action.t) ->
        let status =
          match action with
          | Setup_mdexp -> "Available"
        in
        Cell.text status)
    ]
  in
  let print_table = Print_table.make ~columns ~rows:Action.all in
  print_endline (Print_table.to_string_markdown print_table);
  (* @mdexp.snapshot *)
  [%expect
    {|
    | Action      | Description                                     |  Status   |
    |:------------|:------------------------------------------------|:---------:|
    | setup-mdexp | Download and install mdexp from GitHub releases | Available |
    |}]
;;

(* @mdexp

## Supported Platforms

The setup-mdexp action supports the following platforms: *)

module Platform = struct
  type t =
    | Ubuntu
    | MacOS

  let all = [ Ubuntu; MacOS ]
end

let%expect_test "platforms table" =
  let open Print_table.O in
  let columns : Platform.t Column.t list =
    [ Column.make ~header:"Platform" (fun (platform : Platform.t) ->
        let name =
          match platform with
          | Ubuntu -> "ubuntu-latest"
          | MacOS -> "macos-latest"
        in
        Cell.text name)
    ; Column.make ~header:"Architecture" (fun (platform : Platform.t) ->
        let arch =
          match platform with
          | Ubuntu -> "x86_64"
          | MacOS -> "arm64"
        in
        Cell.text arch)
    ; Column.make ~header:"Tested" ~align:Center (fun (platform : Platform.t) ->
        let tested =
          match platform with
          | Ubuntu -> "Yes"
          | MacOS -> "Yes"
        in
        Cell.text tested)
    ]
  in
  let print_table = Print_table.make ~columns ~rows:Platform.all in
  print_endline (Print_table.to_string_markdown print_table);
  (* @mdexp.snapshot *)
  [%expect
    {|
    | Platform      | Architecture | Tested |
    |:--------------|:-------------|:------:|
    | ubuntu-latest | x86_64       |  Yes   |
    | macos-latest  | arm64        |  Yes   |
    |}]
;;

(* @mdexp

## How It Works

The `setup-mdexp` action:

1. Downloads the correct binary for the runner's OS and architecture (prefers compressed archives, falls back to raw binary)
2. Verifies binary integrity via SHA256 digest
3. Verifies build attestation using `gh` CLI
4. Installs the binary to a temporary directory
5. Adds the directory to `PATH` for subsequent steps

See the [setup-mdexp README](../setup-mdexp/README.md) for usage details. *)
