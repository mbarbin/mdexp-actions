(*********************************************************************************)
(*  mdexp-actions - Reusable GitHub Actions for the mdexp tool                   *)
(*  SPDX-FileCopyrightText: 2026 Mathieu Barbin <mathieu.barbin@gmail.com>       *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

(* @mdexp

# Known SHA256 Digests

This file lists the SHA256 digests for mdexp binaries distributed via
[GitHub Releases](https://github.com/mbarbin/mdexp/releases/). Use these values
with the required `mdexp-digest` input of `setup-mdexp` to verify the integrity
of the downloaded binary.

Only the `linux-x86_64` platform is listed below, as it covers the most common
CI runner configuration. For other platforms, please refer to the official
[mdexp releases page](https://github.com/mbarbin/mdexp/releases/).
*)

module Platform = struct
  type t = Linux_x86_64

  let to_string = function
    | Linux_x86_64 -> "linux-x86_64"
  ;;
end

module Digest_entry = struct
  type t =
    { version : string
    ; platform : Platform.t
    ; digest : string
    }
end

let digests : Digest_entry.t list =
  [ { version = "0.0.20260315"
    ; platform = Linux_x86_64
    ; digest = "sha256:f4fc53bcaa50c9dd979b968804c38322b9b7e6aa699d9d6d2d1f101965332018"
    }
  ]
;;

let%expect_test "digests table" =
  let open Print_table.O in
  let open Digest_entry in
  let columns : t Column.t list =
    [ Column.make ~header:"Version" ~align:Center (fun d ->
        Cell.text
          (Printf.sprintf
             "[%s](https://github.com/mbarbin/mdexp/releases/tag/%s)"
             d.version
             d.version))
    ; Column.make ~header:"Platform" ~align:Center (fun d ->
        Cell.text (Platform.to_string d.platform))
    ; Column.make ~header:"Digest" (fun d -> Cell.text (Printf.sprintf "`%s`" d.digest))
    ]
  in
  let print_table = Print_table.make ~columns ~rows:digests in
  print_endline (Print_table.to_string_markdown print_table);
  (* @mdexp.snapshot *)
  [%expect
    {|
    |                                  Version                                   |   Platform   | Digest                                                                    |
    |:--------------------------------------------------------------------------:|:------------:|:--------------------------------------------------------------------------|
    | [0.0.20260315](https://github.com/mbarbin/mdexp/releases/tag/0.0.20260315) | linux-x86_64 | `sha256:f4fc53bcaa50c9dd979b968804c38322b9b7e6aa699d9d6d2d1f101965332018` |
    |}]
;;

(* @mdexp

_This table will be updated as new releases are published._ *)
