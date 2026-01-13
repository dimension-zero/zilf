#!/usr/bin/env pwsh
#Requires -PSEdition Core
#Requires -Version 7.0

<#
.SYNOPSIS
    Audits a git repository for commits containing AI assistant self-promotion.

.DESCRIPTION
    Uses LibGit2Sharp (via a temporary dotnet project) to scan commit history for
    references to Claude, Claude Code, Anthropic, Assistant, or AI Assistant in
    commit authors, co-authors, or message bodies.

.PARAMETER RepositoryPath
    Path to the git repository. Defaults to current directory.

.EXAMPLE
    ./Audit-SelfPromotion.ps1
    ./Audit-SelfPromotion.ps1 -RepositoryPath /path/to/repo
#>

param(
    [Parameter(Position = 0)]
    [string]$RepositoryPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$tempDir = Join-Path ([IO.Path]::GetTempPath()) ("audit_selfpromo_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    $csprojContent = @'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="LibGit2Sharp" Version="0.30.0" />
  </ItemGroup>
</Project>
'@

    $programContent = @'
using System.Text.RegularExpressions;
using LibGit2Sharp;

var repoPath = args.Length > 0 ? args[0] : Directory.GetCurrentDirectory();

var patterns = new[]
{
    @"Claude",
    @"Claude Code",
    @"Anthropic",
    @"\bAssistant\b",
    @"AI Assistant",
    @"Generated with \[Claude",
    @"Co-Authored-By:.*Claude",
    @"Co-Authored-By:.*Anthropic",
    @"Co-Authored-By:.*Assistant"
};

var combinedPattern = new Regex(string.Join("|", patterns), RegexOptions.IgnoreCase);

Console.WriteLine($"Auditing repository for AI self-promotion: {repoPath}");
Console.WriteLine();

using var repo = new Repository(repoPath);

var flaggedCommits = new List<(string Sha, string Date, string Author, string Subject, List<(string Location, string Text)> Findings)>();
int totalCommits = 0;

foreach (var commit in repo.Commits)
{
    totalCommits++;
    var findings = new List<(string Location, string Text)>();

    // Check author
    var authorString = $"{commit.Author.Name} <{commit.Author.Email}>";
    if (combinedPattern.IsMatch(authorString))
    {
        findings.Add(("Author", authorString));
    }

    // Check committer
    var committerString = $"{commit.Committer.Name} <{commit.Committer.Email}>";
    if (combinedPattern.IsMatch(committerString) && committerString != authorString)
    {
        findings.Add(("Committer", committerString));
    }

    // Check message body
    var message = commit.Message;
    if (combinedPattern.IsMatch(message))
    {
        var matchedLines = message.Split('\n')
            .Where(line => combinedPattern.IsMatch(line))
            .Select(line => line.Trim());

        foreach (var line in matchedLines)
        {
            findings.Add(("Message", line));
        }
    }

    if (findings.Count > 0)
    {
        var subject = commit.MessageShort.Replace("\n", " ");
        if (subject.Length > 50) subject = subject[..50];

        flaggedCommits.Add((
            commit.Sha[..8],
            commit.Author.When.ToString("yyyy-MM-dd"),
            commit.Author.Name,
            subject,
            findings
        ));
    }
}

Console.WriteLine($"Scanned {totalCommits} commits");
Console.WriteLine();

if (flaggedCommits.Count == 0)
{
    Console.ForegroundColor = ConsoleColor.Green;
    Console.WriteLine("No AI self-promotion found.");
    Console.ResetColor();
}
else
{
    Console.ForegroundColor = ConsoleColor.Yellow;
    Console.WriteLine($"Found {flaggedCommits.Count} commits with AI self-promotion:");
    Console.ResetColor();
    Console.WriteLine();

    foreach (var fc in flaggedCommits)
    {
        Console.ForegroundColor = ConsoleColor.White;
        Console.WriteLine($"{fc.Sha} ({fc.Date}) - {fc.Subject}...");
        Console.ForegroundColor = ConsoleColor.Gray;
        Console.WriteLine($"  Author: {fc.Author}");
        Console.ForegroundColor = ConsoleColor.Magenta;
        foreach (var finding in fc.Findings)
        {
            Console.WriteLine($"  [{finding.Location}] {finding.Text}");
        }
        Console.ResetColor();
        Console.WriteLine();
    }
}
'@

    Set-Content -Path (Join-Path $tempDir 'AuditSelfPromo.csproj') -Value $csprojContent
    Set-Content -Path (Join-Path $tempDir 'Program.cs') -Value $programContent

    Write-Host "Building audit tool..." -ForegroundColor Gray
    $restoreResult = dotnet restore $tempDir 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet restore failed: $restoreResult"
    }

    dotnet run --project $tempDir -- $RepositoryPath
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
