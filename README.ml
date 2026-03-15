(*********************************************************************************)
(*  mdexp-actions - Reusable GitHub Actions for the mdexp tool                   *)
(*  SPDX-FileCopyrightText: 2026 Mathieu Barbin <mathieu.barbin@gmail.com>       *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

(* @mdexp

# mdexp-actions

Reusable GitHub Actions for the [mdexp](https://github.com/mbarbin/mdexp) literate programming tool.

[![CI](https://github.com/mbarbin/mdexp-actions/actions/workflows/ci.yml/badge.svg)](https://github.com/mbarbin/mdexp-actions/actions/workflows/ci.yml)
[![Test](https://github.com/mbarbin/mdexp-actions/actions/workflows/test-setup-mdexp.yml/badge.svg)](https://github.com/mbarbin/mdexp-actions/actions/workflows/test-setup-mdexp.yml)
[![Release](https://github.com/mbarbin/mdexp-actions/actions/workflows/create-release-on-tag.yml/badge.svg)](https://github.com/mbarbin/mdexp-actions/actions/workflows/create-release-on-tag.yml)

## Actions

- [`setup-mdexp`](./setup-mdexp/README.md): Install the mdexp executable for use in workflows.

## Compatibility *)

module Compatibility = struct
  module Row = struct
    type t =
      { action_version : string
      ; cli_version : string
      ; status : string
      ; note : string
      }
  end

  let rows : Row.t list =
    [ { action_version = "v1.0.0-alpha.1"
      ; cli_version = "0.0.20260315"
      ; status = "✅"
      ; note = "latest, recommended"
      }
    ]
  ;;
end

let%expect_test "compatibility table" =
  let open Print_table.O in
  let open Compatibility.Row in
  let columns : t Column.t list =
    [ Column.make ~header:"Action Version" ~align:Center (fun c ->
        Cell.text c.action_version)
    ; Column.make ~header:"CLI mdexp Version" ~align:Center (fun c ->
        Cell.text c.cli_version)
    ; Column.make ~header:"Status" ~align:Center (fun c -> Cell.text c.status)
    ; Column.make ~header:"Note" (fun c -> Cell.text c.note)
    ]
  in
  let print_table = Print_table.make ~columns ~rows:Compatibility.rows in
  print_endline (Print_table.to_string_markdown print_table);
  (* @mdexp.snapshot *)
  [%expect
    {|
    | Action Version | CLI mdexp Version | Status | Note                |
    |:--------------:|:-----------------:|:------:|:--------------------|
    | v1.0.0-alpha.1 |   0.0.20260315    |  ✅   | latest, recommended |
    |}]
;;

(* @mdexp

_This table will be updated as new versions are released._

## Usage, Documentation, Links & Resources

- See each action's `README` or `action.yml` for detailed usage and options.
- The documentation of the [mdexp](https://mbarbin.github.io/mdexp/) tool. *)
