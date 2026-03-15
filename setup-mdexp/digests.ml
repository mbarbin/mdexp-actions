(*********************************************************************************)
(*  mdexp-actions - Reusable GitHub Actions for the mdexp tool                   *)
(*  SPDX-FileCopyrightText: 2026 Mathieu Barbin <mathieu.barbin@gmail.com>       *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

(* @mdexp

# Known SHA256 Digests

This file lists the SHA256 digests for mdexp binaries. Use these values with the
required `mdexp-digest` input of `setup-mdexp` to verify the integrity of the
downloaded binary.

Only the `linux-x86_64` platform is listed below, as it covers the most common
CI runner configuration. For other platforms, please refer to the official
[mdexp releases page](https://github.com/mbarbin/mdexp/releases/).
*)

module Digest_entry = struct
  type t =
    { version : string
    ; platform : string
    ; digest : string
    }
end

let digests : Digest_entry.t list =
  [ { version = "TBD"; platform = "linux-x86_64"; digest = "sha256:TBD" } ]
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
    ; Column.make ~header:"Platform" ~align:Center (fun d -> Cell.text d.platform)
    ; Column.make ~header:"Digest" (fun d -> Cell.text (Printf.sprintf "`%s`" d.digest))
    ]
  in
  let print_table = Print_table.make ~columns ~rows:digests in
  print_endline (Print_table.to_string_markdown print_table);
  (* @mdexp.snapshot *)
  [%expect
    {|
    |                         Version                          |   Platform   | Digest       |
    |:--------------------------------------------------------:|:------------:|:-------------|
    | [TBD](https://github.com/mbarbin/mdexp/releases/tag/TBD) | linux-x86_64 | `sha256:TBD` |
    |}]
;;

(* @mdexp

_This table will be updated as new releases are published._ *)
