#!/usr/bin/env pwsh
#Requires -PSEdition Core
#Requires -Version 7.0

dotnet test test/Zilf.Tests.Integration -c Debug --filter "ClassName=Zilf.Tests.Integration.ZilLibTests" --logger "console;verbosity=minimal" @args
