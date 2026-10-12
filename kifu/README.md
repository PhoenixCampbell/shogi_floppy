Put match records in this folder. Both builds list and load `.csa` files.
The modern build uses `kifu/`; the Amstrad build uses
`KIFU\` and requires only the filename at the prompt.

USI records may use the standard command form:

```text
position startpos moves 7g7f 3c3d 2g2f
```

USI move lists may also contain one move per line. Promotions use a trailing
plus (for example, `2b3c+`); drops use piece and destination (for example,
`P*5e`). Coordinates follow USI: files 1-9 and ranks a-i.

CSA files may contain standard move rows such as `+7776FU` and `-3334FU`.
The viewer starts from the normal initial board, so custom CSA starting
positions are not supported. A record can contain up to 512 plies.
