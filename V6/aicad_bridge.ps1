param(
  [Parameter(Mandatory = $true)]
  [string]$RequestFile,

  [Parameter(Mandatory = $true)]
  [string]$ResponseFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Response {
  param(
    [string]$Status,
    [string]$Message,
    [string]$TargetCommand = '',
    [string]$Height = '',
    [string]$WidthFactor = '',
    [string]$ColorIndex = '',
    [string]$Spacing = '',
    [string]$SearchText = '',
    [string]$ReplaceText = '',
    [string]$ReplaceCount = '',
    [string]$TargetType = '',
    [string]$DeltaX = '',
    [string]$DeltaY = ''
  )

  $safeMessage = ($Message -replace "`r|`n", ' ').Trim()
  $lines = @(
    "status=$Status"
    "message=$safeMessage"
    "target_command=$TargetCommand"
    "height=$Height"
    "width_factor=$WidthFactor"
    "color_index=$ColorIndex"
    "spacing=$Spacing"
    "search_text=$SearchText"
    "replace_text=$ReplaceText"
    "replace_count=$ReplaceCount"
    "target_type=$TargetType"
    "delta_x=$DeltaX"
    "delta_y=$DeltaY"
  )
  Set-Content -Path $ResponseFile -Value $lines -Encoding Default
}

function Add-ResponseReplacePairs {
  param(
    [string]$Path,
    [object[]]$Pairs
  )

  $index = 1
  foreach ($pair in $Pairs) {
    $searchText = ([string](Get-ObjectMemberValue $pair 'search_text')) -replace "`r|`n", ' '
    $replaceText = ([string](Get-ObjectMemberValue $pair 'replace_text')) -replace "`r|`n", ' '
    Add-Content -Path $Path -Value "replace_pair_${index}_search=$searchText" -Encoding Default
    Add-Content -Path $Path -Value "replace_pair_${index}_replace=$replaceText" -Encoding Default
    $index++
  }
}

function Get-ObjectMemberValue {
  param(
    [object]$Object,
    [string]$Name
  )

  if ($null -eq $Object) {
    return $null
  }

  if ($Object -is [System.Collections.IDictionary]) {
    if ($Object.Contains($Name)) {
      return $Object[$Name]
    }
    return $null
  }

  $property = $Object.PSObject.Properties[$Name]
  if ($property) {
    return $property.Value
  }

  return $null
}

function Get-ContentText {
  param([object]$ContentValue)

  if ($ContentValue -is [string]) {
    return $ContentValue
  }

  if ($ContentValue -is [System.Array]) {
    return (($ContentValue | ForEach-Object {
      if ($_ -is [string]) { $_ }
      elseif ($_ -and $_.PSObject.Properties['text']) { [string]$_.text }
      else { [string]$_ }
    }) -join '')
  }

  return [string]$ContentValue
}

function Normalize-JsonText {
  param([string]$Text)

  $trimmed = $Text.Trim()
  if ($trimmed.StartsWith('```')) {
    $trimmed = [regex]::Replace($trimmed, '^```(?:json)?\s*', '')
    $trimmed = [regex]::Replace($trimmed, '\s*```$', '')
  }
  return $trimmed.Trim()
}

function Get-AsciiMessage {
  param([string]$Message)

  if ([string]::IsNullOrWhiteSpace($Message)) {
    return ''
  }

  return ($Message -replace '[^\u0000-\u007F]', '?')
}

function Get-HttpErrorMessage {
  param([System.Exception]$Exception)

  $statusCode = ''
  $responseBody = ''

  if ($Exception.PSObject.Properties['Response'] -and $Exception.Response) {
    try {
      if ($Exception.Response.PSObject.Properties['StatusCode']) {
        $statusCode = [string][int]$Exception.Response.StatusCode
      }
    }
    catch {
      $statusCode = ''
    }

    try {
      $stream = $Exception.Response.GetResponseStream()
      if ($stream) {
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        $reader.Dispose()
        $stream.Dispose()
      }
    }
    catch {
      $responseBody = ''
    }
  }

  $baseMessage = if ([string]::IsNullOrWhiteSpace($statusCode)) {
    'HTTP request failed'
  } else {
    "HTTP request failed with status $statusCode"
  }

  if (-not [string]::IsNullOrWhiteSpace($responseBody)) {
    $body = Get-AsciiMessage $responseBody
    return "$baseMessage | body=$body"
  }

  $message = Get-AsciiMessage $Exception.Message
  if (-not [string]::IsNullOrWhiteSpace($message)) {
    return "$baseMessage | message=$message"
  }

  return $baseMessage
}

function Get-PositiveDoubleString {
  param(
    [object]$Value,
    [string]$FieldName
  )

  if ($null -eq $Value) {
    throw "AI response is missing $FieldName."
  }

  $number = [double]$Value
  if ($number -le 0) {
    throw "AI response returned a non-positive $FieldName."
  }

  return $number.ToString([System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-PositiveIntString {
  param(
    [object]$Value,
    [string]$FieldName
  )

  if ($null -eq $Value) {
    throw "AI response is missing $FieldName."
  }

  $number = [int]$Value
  if ($number -le 0) {
    throw "AI response returned a non-positive $FieldName."
  }

  return [string]$number
}

function Get-FirstNumberString {
  param([string]$Text)

  $match = [regex]::Match($Text, '[-+]?\d*\.?\d+')
  if ($match.Success) {
    return $match.Value
  }

  if ($Text -match '\u4e8c\u5341') { return '20' }
  if ($Text -match '\u5341') { return '10' }
  if ($Text -match '\u4e24') { return '2' }
  if ($Text -match '\u4e00') { return '1' }
  if ($Text -match '\u4e8c') { return '2' }
  if ($Text -match '\u4e09') { return '3' }
  if ($Text -match '\u56db') { return '4' }
  if ($Text -match '\u4e94') { return '5' }
  if ($Text -match '\u516d') { return '6' }
  if ($Text -match '\u4e03') { return '7' }
  if ($Text -match '\u516b') { return '8' }
  if ($Text -match '\u4e5d') { return '9' }

  return $null
}

function Get-LocalColorIndex {
  param([string]$Instruction)

  $text = $Instruction.ToLowerInvariant()

  if ($text -match 'red|hong|\u7ea2') { return '1' }
  if ($text -match 'yellow|huang|\u9ec4') { return '2' }
  if ($text -match 'green|lv|\u7eff') { return '3' }
  if ($text -match 'cyan|qing|\u9752') { return '4' }
  if ($text -match 'blue|lan|\u84dd') { return '5' }
  if ($text -match 'magenta|pink|pin|zi|\u54c1\u7ea2|\u6d0b\u7ea2|\u7d2b') { return '6' }
  if ($text -match 'white|bai|\u767d') { return '7' }

  return $null
}

function Normalize-ReplacementOperand {
  param(
    [string]$Text,
    [switch]$IsSearch
  )

  if ($null -eq $Text) {
    return ''
  }

  # Only strip surrounding single/double quotes. Do NOT trim whitespace —
  # pure spaces are valid search/replace operands (e.g. delete spaces).
  $trimmedQuotes = $Text.Trim("'" + [char]34)

  if ($IsSearch) {
    # Empty after quote strip is invalid; pure whitespace is valid.
    return $trimmedQuotes
  }

  return $trimmedQuotes
}

function Test-NonEmptySearchOperand {
  param([string]$Text)
  return -not [string]::IsNullOrEmpty($Text)
}

function Get-LocalReplacePairs {
  param([string]$Instruction)

  $pairs = @()
  $segments = @(
    [regex]::Split($Instruction, '\s*(?:,|\uFF0C|;|\uFF1B)\s*') |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )

  if ($segments.Count -eq 0) {
    return @()
  }

  foreach ($segment in $segments) {
    $fromText = $null
    $toText = $null

    # 1) Verb-first delete space
    $deleteSpace = [regex]::Match(
      $segment,
      '^\s*(?:\u5220\u9664|\u53bb\u6389|remove|delete)\s*(?:\u7a7a\u683c|space|spaces|\u534a\u89d2\u7a7a\u683c)\s*$',
      [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    if ($deleteSpace.Success) {
      $fromText = ' '
      $toText = ''
    }

    # 2) Keyword space as from
    if ($null -eq $fromText) {
      $kw = [regex]::Match(
        $segment,
        '^\s*(?:\u628a|\u5c06)?\s*(?:\u7a7a\u683c|space|spaces|\u534a\u89d2\u7a7a\u683c)\s*(?:\u6539\u4e3a|\u6539\u6210|\u66ff\u6362\u4e3a|\u66ff\u6362\u6210|\u6362\u6210|replace\s+with|to)?\s*(?<to>.*?)\s*$',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
      )
      if ($kw.Success) {
        $fromText = ' '
        $toText = Normalize-ReplacementOperand $kw.Groups['to'].Value
        if ($toText -match '^(?:\u7a7a\u683c|space|spaces)$') { $toText = ' ' }
        if ($toText -match '^(?:\u7a7a|empty|nothing|\u65e0)$') { $toText = '' }
      }
    }

    # 3) General form; from may be single space
    if ($null -eq $fromText) {
      $match = [regex]::Match(
        $segment,
        '^\s*(?:\u628a|\u5c06)?\s*(?<from>.+?)\s*(?:\u6539\u4e3a|\u6539\u6210|\u66ff\u6362\u4e3a|\u66ff\u6362\u6210|\u6362\u6210|replace\s+with|to)\s*(?<to>.*?)\s*$',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
      )
      if (-not $match.Success) {
        return @()
      }

      $fromText = Normalize-ReplacementOperand $match.Groups['from'].Value -IsSearch
      $toText = Normalize-ReplacementOperand $match.Groups['to'].Value

      if ($fromText -match '^(?:\u7a7a\u683c|space|spaces)$') { $fromText = ' ' }
      if ($toText -match '^(?:\u7a7a\u683c|space|spaces)$') { $toText = ' ' }
      if ($toText -match '^(?:\u7a7a|empty|nothing|\u65e0)$') { $toText = '' }
    }

    if (-not (Test-NonEmptySearchOperand $fromText)) {
      return @()
    }

    $pairs += [pscustomobject]@{
      search_text = $fromText
      replace_text = $toText
    }
  }

  return $pairs
}


function Get-ReplacementPairsFromDecision {
  param([object]$Arguments)

  $pairs = @()
  $rawReplacements = Get-ObjectMemberValue $Arguments 'replacements'

  if ($null -ne $rawReplacements) {
    foreach ($item in @($rawReplacements)) {
      $searchText = Normalize-ReplacementOperand ([string](Get-ObjectMemberValue $item 'search_text')) -IsSearch
      $rawReplace = Get-ObjectMemberValue $item 'replace_text'
      if ($null -eq $rawReplace) {
        # Missing key is an error; empty string is allowed (delete match).
        throw 'AI response is missing arguments.replacements[].replace_text.'
      }
      $replaceText = Normalize-ReplacementOperand ([string]$rawReplace)
      if (-not (Test-NonEmptySearchOperand $searchText)) {
        throw 'AI response is missing arguments.replacements[].search_text.'
      }
      if ($searchText -match '^(?:\u7a7a\u683c|space|spaces)$') {
        $searchText = ' '
      }
      if ($replaceText -match '^(?:\u7a7a\u683c|space|spaces)$') {
        $replaceText = ' '
      }
      if ($replaceText -match '^(?:\u7a7a|empty|nothing|\u65e0)$') {
        $replaceText = ''
      }
      $pairs += [pscustomobject]@{
        search_text = $searchText
        replace_text = $replaceText
      }
    }
  }

  if ($pairs.Count -eq 0) {
    $searchText = Normalize-ReplacementOperand ([string](Get-ObjectMemberValue $Arguments 'search_text')) -IsSearch
    $rawReplace = Get-ObjectMemberValue $Arguments 'replace_text'
    if ($null -eq $rawReplace) {
      throw 'AI response is missing arguments.replace_text.'
    }
    $replaceText = Normalize-ReplacementOperand ([string]$rawReplace)
    if (-not (Test-NonEmptySearchOperand $searchText)) {
      throw 'AI response is missing arguments.search_text.'
    }
    if ($searchText -match '^(?:\u7a7a\u683c|space|spaces)$') {
      $searchText = ' '
    }
    if ($replaceText -match '^(?:\u7a7a\u683c|space|spaces)$') {
      $replaceText = ' '
    }
    if ($replaceText -match '^(?:\u7a7a|empty|nothing|\u65e0)$') {
      $replaceText = ''
    }
    $pairs += [pscustomobject]@{
      search_text = $searchText
      replace_text = $replaceText
    }
  }

  return $pairs
}

function Resolve-LocalRoute {
  param([string]$Instruction)

  $raw = $Instruction.Trim()
  if ([string]::IsNullOrWhiteSpace($raw)) {
    return $null
  }

  $text = $raw.ToLowerInvariant()
  $number = Get-FirstNumberString $text
  $colorIndex = Get-LocalColorIndex $text
  $replacePairs = @(Get-LocalReplacePairs $raw)
  $moveDirection = $null
  $lineEditMode = $null
  $lineEditSide = $null
  $targetType = 'ALL'

  if ($text -match '\u6587\u5b57|\u6587\u672c|text|mtext') { $targetType = 'TEXT' }
  elseif ($text -match '\u76f4\u7ebf|\u591a\u6bb5\u7ebf|\u77e9\u5f62|\u7ebf|line|polyline|rectangle') { $targetType = 'LINE' }

  if ($text -match '\u5ef6\u957f|extend') {
    $lineEditMode = 'EXTEND'
  }
  elseif ($text -match '\u7f29\u77ed|shorten') {
    $lineEditMode = 'SHORTEN'
  }

  if ($lineEditMode) {
    if ($lineEditMode -eq 'EXTEND') {
      if ($text -match '\u5411\u53f3|\u53f3|right') { $lineEditSide = 'RIGHT' }
      elseif ($text -match '\u5411\u5de6|\u5de6|left') { $lineEditSide = 'LEFT' }
      elseif ($text -match '\u5411\u4e0a|\u4e0a|up') { $lineEditSide = 'UP' }
      elseif ($text -match '\u5411\u4e0b|\u4e0b|down') { $lineEditSide = 'DOWN' }
    }
    else {
      if ($text -match '\u4ece\u5de6\u5411\u53f3|\u4ece\u5de6\u5f80\u53f3|left.*right') { $lineEditSide = 'LEFT' }
      elseif ($text -match '\u4ece\u53f3\u5411\u5de6|\u4ece\u53f3\u5f80\u5de6|right.*left') { $lineEditSide = 'RIGHT' }
      elseif ($text -match '\u4ece\u4e0a\u5411\u4e0b|\u4ece\u4e0a\u5f80\u4e0b|top.*bottom|up.*down') { $lineEditSide = 'UP' }
      elseif ($text -match '\u4ece\u4e0b\u5411\u4e0a|\u4ece\u4e0b\u5f80\u4e0a|bottom.*top|down.*up') { $lineEditSide = 'DOWN' }
    }
  }

  if ($lineEditMode -and $lineEditSide -and $number) {
    return @{
      target_command = 'LINEEDIT'
      arguments = @{
        side = $lineEditSide
        mode = $lineEditMode
        distance = $number
      }
      message = "Edit line objects with mode=$lineEditMode, side=$lineEditSide, distance=$number."
    }
  }

  if ($text -match '\u5411\u53f3\u79fb\u52a8|move.*right|right') { $moveDirection = 'RIGHT' }
  elseif ($text -match '\u5411\u5de6\u79fb\u52a8|move.*left|left') { $moveDirection = 'LEFT' }
  elseif ($text -match '\u5411\u4e0a\u79fb\u52a8|move.*up|up') { $moveDirection = 'UP' }
  elseif ($text -match '\u5411\u4e0b\u79fb\u52a8|move.*down|down') { $moveDirection = 'DOWN' }

  if ($moveDirection -and $number) {
    $dx = '0'
    $dy = '0'
    switch ($moveDirection) {
      'RIGHT' { $dx = $number }
      'LEFT' { $dx = "-$number" }
      'UP' { $dy = $number }
      'DOWN' { $dy = "-$number" }
    }
    return @{
      target_command = 'MOVEOBJ'
      arguments = @{
        target_type = $targetType
        delta_x = $dx
        delta_y = $dy
      }
      message = "Move $targetType objects by dx=$dx, dy=$dy."
    }
  }

  if ($colorIndex -and ($text -match '\u989c\u8272|\u8272|color')) {
    return @{
      target_command = 'Y'
      arguments = @{
        color_index = $colorIndex
        target_type = $targetType
      }
      message = "Set $targetType objects color to ACI $colorIndex."
    }
  }

  if (($text -match '\u95f4\u8ddd|\u6392\u5217|\u6392\u5e03|\u4ece\u4e0a\u5230\u4e0b|top to bottom|spacing') -and ($text -notmatch '\u989c\u8272|color')) {
    $spacing = if ($number) { $number } else { '5' }
    return @{
      target_command = 'HEI'
      arguments = @{ spacing = $spacing }
      message = "Arrange selected text objects with spacing $spacing."
    }
  }

  if ($text -match '\u5de6\u5bf9\u9f50|left align|align.*left') {
    return @{
      target_command = 'ZUO'
      arguments = @{}
      message = 'Left align selected text.'
    }
  }

  if ($text -match '\u53f3\u5bf9\u9f50|right align|align.*right') {
    return @{
      target_command = 'YOU'
      arguments = @{}
      message = 'Right align selected text.'
    }
  }

  if ($text -match '\u4e0a\u5bf9\u9f50|top align|align.*top') {
    return @{
      target_command = 'SHANG'
      arguments = @{}
      message = 'Top align selected text.'
    }
  }

  if ($text -match '\u4e0b\u5bf9\u9f50|bottom align|align.*bottom') {
    return @{
      target_command = 'XIA'
      arguments = @{}
      message = 'Bottom align selected text.'
    }
  }

  if ($text -match '\u5c45\u4e2d\u5bf9\u9f50|\u4e2d\u5fc3\u5bf9\u9f50|center align|centre align|align.*center|align.*centre') {
    return @{
      target_command = 'ZHONG'
      arguments = @{}
      message = 'Center align selected text.'
    }
  }

  if (($text -match '\u5bbd\u5ea6|\u5bbd\u9ad8|\u5bbd\u5ea6\u6bd4\u4f8b|width') -and $number) {
    return @{
      target_command = 'WI'
      arguments = @{ width_factor = $number }
      message = "Set selected text width factor to $number."
    }
  }

  if (($text -match '\u9ad8\u5ea6|\u5b57\u9ad8|height') -and $number) {
    return @{
      target_command = 'QW'
      arguments = @{ height = $number }
      message = "Set selected text height to $number."
    }
  }

  if ($replacePairs.Count -gt 0) {
    $message = if ($replacePairs.Count -eq 1) {
      "Replace text '$((Get-ObjectMemberValue $replacePairs[0] 'search_text'))' with '$((Get-ObjectMemberValue $replacePairs[0] 'replace_text'))'."
    } else {
      "Apply $($replacePairs.Count) ordered text replacements."
    }
    return @{
      target_command = 'RETXT'
      arguments = @{
        replacements = $replacePairs
      }
      message = $message
    }
  }

  return $null
}

try {
  if (-not (Test-Path -LiteralPath $RequestFile)) {
    throw "Request file not found: $RequestFile"
  }

  $apiKey = $env:AICAD_API_KEY
  if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw 'Missing environment variable AICAD_API_KEY.'
  }

  $apiUrl = if ([string]::IsNullOrWhiteSpace($env:AICAD_API_URL)) {
    'https://api.openai.com/v1/chat/completions'
  } else {
    $env:AICAD_API_URL
  }

  $request = Get-Content -LiteralPath $RequestFile -Raw -Encoding Default | ConvertFrom-Json
  $model = if ($env:AICAD_MODEL) { [string]$env:AICAD_MODEL } elseif ($request.model) { [string]$request.model } else { 'gpt-4.1-mini' }
  $decision = Resolve-LocalRoute ([string]$request.user_text)

  if ($null -eq $decision) {
$systemPrompt = @"
You are an AutoCAD command router.
Choose exactly one command from the allowed list, or return NONE if the request is unsupported.
The user may write instructions in English or Chinese. You must understand both.
Only output valid JSON with this shape:
{"target_command":"QW","arguments":{"height":5},"message":"Set selected text height to 5."}

Rules:
- Only choose from the provided allowed commands.
- Never invent commands.
- If the selection summary or instruction does not match the whitelist, return {"target_command":"NONE","arguments":{},"message":"..."}.
- For QW, return arguments.height as a positive number.
- For WI, return arguments.width_factor as a positive number.
- For Y, return arguments.color_index as a positive integer AutoCAD ACI color and arguments.target_type as TEXT, LINE, or ALL.
- For HEI, return arguments.spacing as a positive number. Use 5 if unspecified.
- For RETXT, return either arguments.search_text (non-empty; a single space is valid) and arguments.replace_text (may be empty to delete), or arguments.replacements as an ordered array of {"search_text":"...","replace_text":"..."} objects. Pure whitespace search_text is allowed so spaces can be removed or replaced.
- For MOVEOBJ, return arguments.target_type plus numeric arguments.delta_x and arguments.delta_y.
- For LINEEDIT, return arguments.side, arguments.mode, and arguments.distance.
- For ZUO, YOU, SHANG, XIA, and ZHONG, return an empty arguments object.
- Keep message short and ASCII-only.
"@

  $userPrompt = @"
Instruction:
$($request.user_text)

Selection summary:
$($request.selection_summary)

Allowed commands:
$($request.allowed_commands)
"@

  $body = @{
    model       = $model
    temperature = 0
    messages    = @(
      @{ role = 'system'; content = $systemPrompt }
      @{ role = 'user'; content = $userPrompt }
    )
  } | ConvertTo-Json -Depth 6

  $headers = @{
    Authorization = "Bearer $apiKey"
    'Content-Type' = 'application/json'
  }

  $apiResponse = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $body
  $contentText = Get-ContentText $apiResponse.choices[0].message.content
  $decision = Normalize-JsonText $contentText | ConvertFrom-Json
  }

  $targetCommand = ([string]$decision.target_command).ToUpperInvariant()
  $message = if ($decision.message) { [string]$decision.message } else { '' }

  switch ($targetCommand) {
    'QW' {
      $height = Get-PositiveDoubleString -Value $decision.arguments.height -FieldName 'arguments.height'
      Write-Response -Status 'OK' -Message $message -TargetCommand 'QW' -Height $height
    }
    'WI' {
      $widthFactor = Get-PositiveDoubleString -Value $decision.arguments.width_factor -FieldName 'arguments.width_factor'
      Write-Response -Status 'OK' -Message $message -TargetCommand 'WI' -WidthFactor $widthFactor
    }
    'Y' {
      $colorIndex = Get-PositiveIntString -Value $decision.arguments.color_index -FieldName 'arguments.color_index'
      $targetType = [string]$decision.arguments.target_type
      if ([string]::IsNullOrWhiteSpace($targetType)) {
        $targetType = 'ALL'
      }
      Write-Response -Status 'OK' -Message $message -TargetCommand 'Y' -ColorIndex $colorIndex -TargetType $targetType
    }
    'HEI' {
      $spacing = Get-PositiveDoubleString -Value $decision.arguments.spacing -FieldName 'arguments.spacing'
      Write-Response -Status 'OK' -Message $message -TargetCommand 'HEI' -Spacing $spacing
    }
    'RETXT' {
      $replacePairs = @(Get-ReplacementPairsFromDecision $decision.arguments)
      $searchText = [string](Get-ObjectMemberValue $replacePairs[0] 'search_text')
      $replaceText = [string](Get-ObjectMemberValue $replacePairs[0] 'replace_text')
      Write-Response -Status 'OK' -Message $message -TargetCommand 'RETXT' -SearchText $searchText -ReplaceText $replaceText -ReplaceCount ([string]$replacePairs.Count)
      Add-ResponseReplacePairs -Path $ResponseFile -Pairs $replacePairs
    }
    'MOVEOBJ' {
      $targetType = [string]$decision.arguments.target_type
      if ([string]::IsNullOrWhiteSpace($targetType)) {
        $targetType = 'ALL'
      }
      $deltaX = [string]$decision.arguments.delta_x
      $deltaY = [string]$decision.arguments.delta_y
      if ([string]::IsNullOrWhiteSpace($deltaX)) {
        throw 'AI response is missing arguments.delta_x.'
      }
      if ([string]::IsNullOrWhiteSpace($deltaY)) {
        throw 'AI response is missing arguments.delta_y.'
      }
      [void][double]$deltaX
      [void][double]$deltaY
      Write-Response -Status 'OK' -Message $message -TargetCommand 'MOVEOBJ' -TargetType $targetType -DeltaX $deltaX -DeltaY $deltaY
    }
    'LINEEDIT' {
      $side = [string]$decision.arguments.side
      $mode = [string]$decision.arguments.mode
      $distance = Get-PositiveDoubleString -Value $decision.arguments.distance -FieldName 'arguments.distance'
      if ([string]::IsNullOrWhiteSpace($side)) {
        throw 'AI response is missing arguments.side.'
      }
      if ([string]::IsNullOrWhiteSpace($mode)) {
        throw 'AI response is missing arguments.mode.'
      }
      Write-Response -Status 'OK' -Message $message -TargetCommand 'LINEEDIT' -TargetType 'LINE' -SearchText '' -ReplaceText '' -Height '' -WidthFactor '' -ColorIndex '' -Spacing '' -DeltaX '' -DeltaY ''
      Add-Content -Path $ResponseFile -Value "side=$side" -Encoding Default
      Add-Content -Path $ResponseFile -Value "mode=$mode" -Encoding Default
      Add-Content -Path $ResponseFile -Value "distance=$distance" -Encoding Default
    }
    'ZUO' {
      Write-Response -Status 'OK' -Message $message -TargetCommand 'ZUO'
    }
    'YOU' {
      Write-Response -Status 'OK' -Message $message -TargetCommand 'YOU'
    }
    'SHANG' {
      Write-Response -Status 'OK' -Message $message -TargetCommand 'SHANG'
    }
    'XIA' {
      Write-Response -Status 'OK' -Message $message -TargetCommand 'XIA'
    }
    'ZHONG' {
      Write-Response -Status 'OK' -Message $message -TargetCommand 'ZHONG'
    }
    'NONE' {
      if ([string]::IsNullOrWhiteSpace($message)) {
        $message = 'The current whitelist does not support this request.'
      }
      Write-Response -Status 'UNSUPPORTED' -Message $message -TargetCommand 'NONE'
    }
    default {
      throw "AI returned unsupported target_command: $targetCommand"
    }
  }
}
catch {
  $message = if ($_.Exception) { Get-HttpErrorMessage $_.Exception } else { 'Unknown bridge error' }
  Write-Response -Status 'ERROR' -Message $message
  exit 1
}
