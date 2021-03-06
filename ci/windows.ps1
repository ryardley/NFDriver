<#
 * Copyright (c) 2018 Spotify AB.
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 #>
param (
    [string]$build = "windows"
 )

Write-Host "NFDriver build process starting..."
Write-Host $build

try
{
	# Upgrade pip or else the CI will complain
	c:\python27\python.exe -m pip install --upgrade pip

	# Start virtualenv
	pip install virtualenv
	virtualenv nfdriver_env

	& ./nfdriver_env/Scripts/activate.bat

	# Install Python Packages
	& nfdriver_env/Scripts/pip.exe install urllib3 `
										pyyaml `
										flake8 `
										cmakelint

	if($build -eq "android"){
		& nfdriver_env/Scripts/python.exe ci/androidwindows.py
	} else {
		& nfdriver_env/Scripts/python.exe ci/windows.py build
	}

	if($LASTEXITCODE -ne 0){
		exit $LASTEXITCODE
	}

	& ./nfdriver_env/Scripts/deactivate.bat
}
catch
{
	echo $_.Exception|format-list -force
	exit 1
}
