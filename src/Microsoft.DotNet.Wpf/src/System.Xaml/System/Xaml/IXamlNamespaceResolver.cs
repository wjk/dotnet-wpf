﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System.Collections.Generic;

namespace System.Xaml
{
    public interface IXamlNamespaceResolver
    {
        string GetNamespace(string prefix);
        IEnumerable<NamespaceDeclaration> GetNamespacePrefixes();
    }
}
