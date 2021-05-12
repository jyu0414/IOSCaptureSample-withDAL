//
//  Main.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import Foundation
import CoreMediaIO

@_cdecl("iOSMirrorMain")
public func iOSMirrorMain(allocator: CFAllocator, requestedTypeUUID: CFUUID) -> CMIOHardwarePlugInRef {
    return pluginRef
}
