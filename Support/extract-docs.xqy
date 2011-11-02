let $doc := xdmp:document-get("/media/psf/Home/Downloads/MarkLogic_5.0ea_pubs/pubs/apidocs/all-builtin-function.txt")
let $functions :=
  for $line in tokenize($doc, "\n")[. != ""]
  let $func := fn:replace($line, "declare\s+function\s+([^\(]+)\(.*", "$1")
  let $regex := fn:concat(".*", $func, "\((.*)\)\sas.*")
  let $params := fn:replace($line, $regex, "$1")
  return
  <func>
    <name>{$func}</name>
    <params>
    {
      for $p at $i in fn:tokenize($params, ", ")
      return
        <param>{fn:normalize-space($p)}</param>
    }
    </params>
  </func>
for $f in fn:distinct-values($functions/name)
let $func := $functions[name = $f]
let $param-counts := 
  for $fun in $func
  return
    fn:count($fun/params/param)
let $min-params := fn:min($param-counts)
let $max-params := fn:max($param-counts)
return
  <dict>
    <key>display</key>
    <string>{$f}</string>
    <key>insert</key>
    <string>
    {
      fn:concat("(",
        fn:string-join(
          for $p at $i in $func/params[fn:count(param) eq $max-params]/param
          let $open-bracket := if ($i > $min-params) then "[" else ()
          let $close-bracket := if ($i > $min-params) then "]" else ()
          return
            fn:concat("${", $i, ":", $open-bracket, fn:replace(fn:normalize-space($p), "\$", "\\\$"), $close-bracket, "}"),
          ", "),
        ")")
    }
    </string>
  </dict>

<dict>
  <key>display</key>
  <string>{$func}</string>
  <key>insert</key>
  <string>
  {
    fn:concat("(",
      fn:string-join(
        for $p at $i in fn:tokenize($params, ", ")
        return
          fn:concat("${", $i, ":", fn:replace(fn:normalize-space($p), "\$", "\\\$"), "}"),
        ", "),
      ")")
  }
  </string>
</dict>