## @file
#  Cryptographic Library Package for UEFI Security Implementation.
#  PEIM, DXE Driver, and SMM Driver with all crypto services enabled.
#
#  Copyright (c) 2009 - 2020, Intel Corporation. All rights reserved.<BR>
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = CryptoPkg
  PLATFORM_GUID                  = E1063286-6C8C-4c25-AEF0-67A9A5B6E6B6
  PLATFORM_VERSION               = 0.98
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/CryptoPkg
  SUPPORTED_ARCHITECTURES        = IA32|X64|AARCH64 # MU_CHANGE turn off ARM
  BUILD_TARGETS                  = DEBUG|RELEASE|NOOPT
  SKUID_IDENTIFIER               = DEFAULT

# MU_CHANGE
!include CryptoPkg/Driver/Packaging/Crypto.inc.dsc
# MU_CHANGE include unittest stuff
!include UnitTestFrameworkPkg/UnitTestFrameworkPkgTarget.dsc.inc

################################################################################
#
# Library Class section - list of all Library Classes needed by this Platform.
#
################################################################################
[LibraryClasses]
  BaseLib|MdePkg/Library/BaseLib/BaseLib.inf
  BaseMemoryLib|MdePkg/Library/BaseMemoryLib/BaseMemoryLib.inf
  PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
  DebugLib|MdePkg/Library/BaseDebugLibNull/BaseDebugLibNull.inf
  UefiBootServicesTableLib|MdePkg/Library/UefiBootServicesTableLib/UefiBootServicesTableLib.inf
  UefiDriverEntryPoint|MdePkg/Library/UefiDriverEntryPoint/UefiDriverEntryPoint.inf
  BaseCryptLib|CryptoPkg/Library/BaseCryptLibNull/BaseCryptLibNull.inf
  TlsLib|CryptoPkg/Library/TlsLibNull/TlsLibNull.inf
  HashApiLib|CryptoPkg/Library/BaseHashApiLib/BaseHashApiLib.inf

##MSCHANGE START Pull in the unit-test library for the VerifyPkcs7EkuUnitTestApp
  FltUsedLib|MdePkg/Library/FltUsedLib/FltUsedLib.inf
  BaseBinSecurityLibRng|MdePkg/Library/BaseBinSecurityLibNull/BaseBinSecurityLibNull.inf
  UnitTestLib|UnitTestFrameworkPkg/Library/UnitTestLib/UnitTestLib.inf
  UnitTestPersistenceLib|UnitTestFrameworkPkg/Library/UnitTestPersistenceLibNull/UnitTestPersistenceLibNull.inf
  UnitTestBootLib|UnitTestFrameworkPkg/Library/UnitTestBootLibNull/UnitTestBootLibNull.inf
  UnitTestResultReportLib|UnitTestFrameworkPkg/Library/UnitTestResultReportLib/UnitTestResultReportLibDebugLib.inf
  UefiApplicationEntryPoint|MdePkg/Library/UefiApplicationEntryPoint/UefiApplicationEntryPoint.inf
  PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
  MemoryAllocationLib|MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf

# Add RNG Libs for ARM
[LibraryClasses.AARCH64, LibraryClasses.ARM]
  RngLib|MdePkg/Library/BaseRngLibNull/BaseRngLibNull.inf

[LibraryClasses.X64, LibraryClasses.IA32]
  RngLib|MdePkg/Library/BaseRngLib/BaseRngLib.inf

[LibraryClasses.AARCH64.DXE_DRIVER, LibraryClasses.ARM.DXE_DRIVER, LibraryClasses.AARCH64.UEFI_APPLICATION, LibraryClasses.ARM.UEFI_APPLICATION]
  RngLib|SecurityPkg/RandomNumberGenerator/RngDxeLib/RngDxeLib.inf

!if $(TOOL_CHAIN_TAG) == VS2017 or $(TOOL_CHAIN_TAG) == VS2015 or $(TOOL_CHAIN_TAG) == VS2019 ##MSCHANGE
[LibraryClasses.IA32]
  NULL|MdePkg/Library/VsIntrinsicLib/VsIntrinsicLib.inf
  ReportStatusCodeLib|MdePkg/Library/BaseReportStatusCodeLibNull/BaseReportStatusCodeLibNull.inf
[LibraryClasses.X64, LibraryClasses.IA32]
  NULL|MdePkg/Library/BaseBinSecurityLibRng/BaseBinSecurityLibRng.inf
  BaseBinSecurityLib|MdePkg/Library/BaseBinSecurityLibRng/BaseBinSecurityLibRng.inf
[LibraryClasses.X64.DXE_CORE, LibraryClasses.X64.UEFI_DRIVER, LibraryClasses.X64.DXE_DRIVER, LibraryClasses.X64.UEFI_APPLICATION]
  # this is currently X64 only because MSVC doesn't support BaseMemoryLibOptDxe for AARCH64
  BaseMemoryLib|MdePkg/Library/BaseMemoryLibOptDxe/BaseMemoryLibOptDxe.inf
!endif ##MSCHANGE

##MSCHANGE End

[LibraryClasses.ARM, LibraryClasses.AARCH64]

  ArmLib|ArmPkg/Library/ArmLib/ArmBaseLib.inf ## MU_CHANGE
  #
  # It is not possible to prevent the ARM compiler for generic intrinsic functions.
  # This library provides the instrinsic functions generate by a given compiler.
  # [LibraryClasses.ARM, LibraryClasses.AARCH64] and NULL mean link this library
  # into all ARM and AARCH64 images.
  #
  NULL|ArmPkg/Library/CompilerIntrinsicsLib/CompilerIntrinsicsLib.inf

  # Add support for stack protector
  NULL|MdePkg/Library/BaseStackCheckLib/BaseStackCheckLib.inf

[LibraryClasses.common.PEIM]
  PeimEntryPoint|MdePkg/Library/PeimEntryPoint/PeimEntryPoint.inf
  MemoryAllocationLib|MdePkg/Library/PeiMemoryAllocationLib/PeiMemoryAllocationLib.inf
  PeiServicesTablePointerLib|MdePkg/Library/PeiServicesTablePointerLib/PeiServicesTablePointerLib.inf
  PeiServicesLib|MdePkg/Library/PeiServicesLib/PeiServicesLib.inf
  HobLib|MdePkg/Library/PeiHobLib/PeiHobLib.inf

[LibraryClasses.common.DXE_SMM_DRIVER]
  SmmServicesTableLib|MdePkg/Library/SmmServicesTableLib/SmmServicesTableLib.inf
  MemoryAllocationLib|MdePkg/Library/SmmMemoryAllocationLib/SmmMemoryAllocationLib.inf
  BaseMemoryLib|MdePkg/Library/BaseMemoryLibRepStr/BaseMemoryLibRepStr.inf # MU_CHANGE added to match current platforms


!if $(CRYPTO_SERVICES) != "PACKAGE" # MU_CHANGE
[LibraryClasses]
  MemoryAllocationLib|MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf
  DebugLib|MdeModulePkg/Library/PeiDxeDebugLibReportStatusCode/PeiDxeDebugLibReportStatusCode.inf
  DebugPrintErrorLevelLib|MdePkg/Library/BaseDebugPrintErrorLevelLib/BaseDebugPrintErrorLevelLib.inf
  OemHookStatusCodeLib|MdeModulePkg/Library/OemHookStatusCodeLibNull/OemHookStatusCodeLibNull.inf
  PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
  DevicePathLib|MdePkg/Library/UefiDevicePathLib/UefiDevicePathLib.inf
  PcdLib|MdePkg/Library/DxePcdLib/DxePcdLib.inf
  TimerLib|MdePkg/Library/BaseTimerLibNullTemplate/BaseTimerLibNullTemplate.inf
  UefiRuntimeServicesTableLib|MdePkg/Library/UefiRuntimeServicesTableLib/UefiRuntimeServicesTableLib.inf  #???
  IoLib|MdePkg/Library/BaseIoLibIntrinsic/BaseIoLibIntrinsic.inf                                          #???
  OpensslLib|CryptoPkg/Library/OpensslLib/OpensslLib.inf
  IntrinsicLib|CryptoPkg/Library/IntrinsicLib/IntrinsicLib.inf
  SafeIntLib|MdePkg/Library/BaseSafeIntLib/BaseSafeIntLib.inf

[LibraryClasses.ARM]
  ArmSoftFloatLib|ArmPkg/Library/ArmSoftFloatLib/ArmSoftFloatLib.inf

[LibraryClasses.common.PEIM]
  PcdLib|MdePkg/Library/PeiPcdLib/PeiPcdLib.inf
  ReportStatusCodeLib|MdeModulePkg/Library/PeiReportStatusCodeLib/PeiReportStatusCodeLib.inf
  BaseCryptLib|CryptoPkg/Library/BaseCryptLib/PeiCryptLib.inf
  TlsLib|CryptoPkg/Library/TlsLibNull/TlsLibNull.inf

[LibraryClasses.IA32.PEIM, LibraryClasses.X64.PEIM]
  PeiServicesTablePointerLib|MdePkg/Library/PeiServicesTablePointerLibIdt/PeiServicesTablePointerLibIdt.inf

[LibraryClasses.ARM.PEIM, LibraryClasses.AARCH64.PEIM]
  PeiServicesTablePointerLib|ArmPkg/Library/PeiServicesTablePointerLib/PeiServicesTablePointerLib.inf

[LibraryClasses.common.DXE_DRIVER, LibraryClasses.common.UEFI_APPLICATION] #MU_CHANGE
  ReportStatusCodeLib|MdeModulePkg/Library/DxeReportStatusCodeLib/DxeReportStatusCodeLib.inf
  BaseCryptLib|CryptoPkg/Library/BaseCryptLib/BaseCryptLib.inf
  TlsLib|CryptoPkg/Library/TlsLib/TlsLib.inf
  DebugLib|MdePkg/Library/UefiDebugLibDebugPortProtocol/UefiDebugLibDebugPortProtocol.inf

[LibraryClasses.common.DXE_SMM_DRIVER]
  ReportStatusCodeLib|MdeModulePkg/Library/SmmReportStatusCodeLib/SmmReportStatusCodeLib.inf
  BaseCryptLib|CryptoPkg/Library/BaseCryptLib/SmmCryptLib.inf
  TlsLib|CryptoPkg/Library/TlsLibNull/TlsLibNull.inf
  DebugLib|MdePkg/Library/BaseDebugLibNull/BaseDebugLibNull.inf
!endif

################################################################################
#
# Pcd Section - list of all EDK II PCD Entries defined by this Platform
#
################################################################################
[PcdsFixedAtBuild]
  gEfiMdePkgTokenSpaceGuid.PcdDebugPropertyMask|0x0f
  gEfiMdePkgTokenSpaceGuid.PcdDebugPrintErrorLevel|0x80000000
  gEfiMdePkgTokenSpaceGuid.PcdReportStatusCodePropertyMask|0x06

## MU_CHANGE Remove PCD definitions

###################################################################################################
#
# Components Section - list of the modules and components that will be processed by compilation
#                      tools and the EDK II tools to generate PE32/PE32+/Coff image files.
#
# Note: The EDK II DSC file is not used to specify how compiled binary images get placed
#       into firmware volume images. This section is just a list of modules to compile from
#       source into UEFI-compliant binaries.
#       It is the FDF file that contains information on combining binary files into firmware
#       volume images, whose concept is beyond UEFI and is described in PI specification.
#       Binary modules do not need to be listed in this section, as they should be
#       specified in the FDF file. For example: Shell binary (Shell_Full.efi), FAT binary (Fat.efi),
#       Logo (Logo.bmp), and etc.
#       There may also be modules listed in this section that are not required in the FDF file,
#       When a module listed here is excluded from FDF file, then UEFI-compliant binary will be
#       generated for it, but the binary will not be put into any firmware volume.
#
###################################################################################################
[Components]
  CryptoPkg/Library/BaseCryptLib/BaseCryptLib.inf # MU_CHANGE add this to pass CI
  CryptoPkg/Test/UnitTest/Library/BaseCryptLib/TestBaseCryptLibUefiShell.inf

!if $(CRYPTO_SERVICES) == PACKAGE
[Components]
  CryptoPkg/Library/BaseCryptLib/PeiCryptLib.inf
  CryptoPkg/Library/BaseCryptLib/RuntimeCryptLib.inf
  CryptoPkg/Library/BaseCryptLibNull/BaseCryptLibNull.inf
  CryptoPkg/Library/IntrinsicLib/IntrinsicLib.inf
  CryptoPkg/Library/TlsLib/TlsLib.inf
  CryptoPkg/Library/TlsLibNull/TlsLibNull.inf
  CryptoPkg/Library/OpensslLib/OpensslLib.inf
  CryptoPkg/Library/OpensslLib/OpensslLibCrypto.inf
  CryptoPkg/Library/BaseHashApiLib/BaseHashApiLib.inf

  CryptoPkg/Library/BaseCryptLibOnProtocolPpi/PeiCryptLib.inf
  CryptoPkg/Library/BaseCryptLibOnProtocolPpi/DxeCryptLib.inf

  # MU_CHANGE START The prebuilt versions of CryptoDriver
  !include CryptoPkg/Driver/Bin/CryptoPkg.ci.inc.dsc
  # MU_CHANGE END

# MU_CHANGE START
[Components.X64, Components.IA32]
  CryptoPkg/Library/BaseCryptLib/SmmCryptLib.inf
  CryptoPkg/Library/BaseCryptLibOnProtocolPpi/SmmCryptLib.inf
# MU_CHANGE END


[Components.X64, Components.IA32]
  ## MU_CHANGE [BEGIN] Added unit-test application for the VerifyEKUsInPkcs7Signature() function.
  # Currently this unit test doesn't work for AARCH64
  CryptoPkg/UnitTests/VerifyPkcs7EkuUnitTestApp/VerifyPkcs7EkuUnitTestApp.inf
  ## MU_CHANGE [END]

!endif

[Components.IA32, Components.X64] # MU_CHANGE remove ARM and AARCH64
  CryptoPkg/Driver/CryptoPei.inf {
    <Defines>
      FILE_GUID = $(PEI_CRYPTO_DRIVER_FILE_GUID)  # MU_CHANGE updated File GUID
  }

[Components.IA32, Components.X64, Components.AARCH64]
  CryptoPkg/Driver/CryptoDxe.inf {
    <Defines>
      FILE_GUID = $(DXE_CRYPTO_DRIVER_FILE_GUID)  # MU_CHANGE updated File GUID
  }

[Components.IA32, Components.X64]
  CryptoPkg/Driver/CryptoSmm.inf {
    <Defines>
      FILE_GUID = $(SMM_CRYPTO_DRIVER_FILE_GUID)# MU_CHANGE updated File GUID
  }


[BuildOptions]
  *_*_*_CC_FLAGS = -D DISABLE_NEW_DEPRECATED_INTERFACES

#MU_CHANGE START
[BuildOptions.common.EDKII.DXE_RUNTIME_DRIVER, BuildOptions.common.EDKII.DXE_SMM_DRIVER, BuildOptions.common.EDKII.SMM_CORE, BuildOptions.common.EDKII.DXE_DRIVER]
  MSFT:*_*_IA32_DLINK_FLAGS = /ALIGN:4096 # enable 4k alignment for MAT and other protections.
  MSFT:*_*_X64_DLINK_FLAGS = /ALIGN:4096 # enable 4k alignment for MAT and other protections.
#MU_CHANGE END