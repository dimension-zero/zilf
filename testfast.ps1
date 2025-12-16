#!/usr/bin/env pwsh
#Requires -PSEdition Core
#Requires -Version 7.0

dotnet test Zilf.sln -c Debug --filter "TestCategory!=Slow" --logger "console;verbosity=minimal" @args
