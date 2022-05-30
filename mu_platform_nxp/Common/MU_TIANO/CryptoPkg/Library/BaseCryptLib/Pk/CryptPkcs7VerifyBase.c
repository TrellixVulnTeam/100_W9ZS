/** @file
  Non-runtime specific implementation of PKCS#7 SignedData Verification Wrapper.

Copyright (c) 2019, Intel Corporation. All rights reserved.<BR>
SPDX-License-Identifier: BSD-2-Clause-Patent

**/

#include "InternalCryptLib.h"

#include <openssl/objects.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/pkcs7.h>

/**
  Extracts the attached content from a PKCS#7 signed data if existed. The input signed
  data could be wrapped in a ContentInfo structure.

  If P7Data, Content, or ContentSize is NULL, then return FALSE. If P7Length overflow,
  then return FALSE. If the P7Data is not correctly formatted, then return FALSE.

  Caution: This function may receive untrusted input. So this function will do
           basic check for PKCS#7 data structure.

  @param[in]   P7Data       Pointer to the PKCS#7 signed data to process.
  @param[in]   P7Length     Length of the PKCS#7 signed data in bytes.
  @param[out]  Content      Pointer to the extracted content from the PKCS#7 signedData.
                            It's caller's responsibility to free the buffer with FreePool().
  @param[out]  ContentSize  The size of the extracted content in bytes.

  @retval     TRUE          The P7Data was correctly formatted for processing.
  @retval     FALSE         The P7Data was not correctly formatted for processing.

**/

// MU_CHANGE [BEGIN] - TCBZ2539
// The below code comes from OpenSSL pk7_doit.c
static int PKCS7_type_is_other(PKCS7 *p7)
{
    int isOther = 1;

    int nid = OBJ_obj2nid(p7->type);

    switch (nid) {
    case NID_pkcs7_data:
    case NID_pkcs7_signed:
    case NID_pkcs7_enveloped:
    case NID_pkcs7_signedAndEnveloped:
    case NID_pkcs7_digest:
    case NID_pkcs7_encrypted:
        isOther = 0;
        break;
    default:
        isOther = 1;
    }

    return isOther;

}

static ASN1_OCTET_STRING *PKCS7_get_octet_string(PKCS7 *p7)
{
    if (PKCS7_type_is_data(p7))
        return p7->d.data;
    if (PKCS7_type_is_other(p7) && p7->d.other
        && (p7->d.other->type == V_ASN1_OCTET_STRING))
        return p7->d.other->value.octet_string;
    return NULL;
}
// MU_CHANGE [END] - TCBZ2539

BOOLEAN
EFIAPI
Pkcs7GetAttachedContent (
  IN  CONST UINT8  *P7Data,
  IN  UINTN        P7Length,
  OUT VOID         **Content,
  OUT UINTN        *ContentSize
  )
{
  BOOLEAN            Status;
  PKCS7              *Pkcs7;
  UINT8              *SignedData;
  UINTN              SignedDataSize;
  BOOLEAN            Wrapped;
  CONST UINT8        *Temp;
  ASN1_OCTET_STRING  *OctStr;

  //
  // Check input parameter.
  //
  if ((P7Data == NULL) || (P7Length > INT_MAX) || (Content == NULL) || (ContentSize == NULL)) {
    return FALSE;
  }

  *Content   = NULL;
  Pkcs7      = NULL;
  SignedData = NULL;
  OctStr     = NULL;

  Status = WrapPkcs7Data (P7Data, P7Length, &Wrapped, &SignedData, &SignedDataSize);
  if (!Status || (SignedDataSize > INT_MAX)) {
    goto _Exit;
  }

  Status = FALSE;

  //
  // Decoding PKCS#7 SignedData
  //
  Temp  = SignedData;
  Pkcs7 = d2i_PKCS7 (NULL, (const unsigned char **)&Temp, (int)SignedDataSize);
  if (Pkcs7 == NULL) {
    goto _Exit;
  }

  //
  // The type of Pkcs7 must be signedData
  //
  if (!PKCS7_type_is_signed (Pkcs7)) {
    goto _Exit;
  }

  //
  // Check for detached or attached content
  //
  if (PKCS7_get_detached (Pkcs7)) {
    //
    // No Content supplied for PKCS7 detached signedData
    //
    *Content     = NULL;
    *ContentSize = 0;
  } else {
    //
    // Retrieve the attached content in PKCS7 signedData
    //
    // MU_CHANGE [BEGIN] - TCBZ2539
    OctStr = PKCS7_get_octet_string(Pkcs7->d.sign->contents);
    DEBUG ((DEBUG_INFO, "OctStr->Type:     %x\n", OctStr->type));
    DEBUG ((DEBUG_INFO, "OctStr->Length:   %x\n", OctStr->length));
    // MU_CHANGE [END] - TCBZ2539
    if ((OctStr->length > 0) && (OctStr->data != NULL)) {
      *ContentSize = OctStr->length;
      *Content     = AllocatePool (*ContentSize);
      if (*Content == NULL) {
        *ContentSize = 0;
        goto _Exit;
      }
      CopyMem (*Content, OctStr->data, *ContentSize);
    }
  }
  Status = TRUE;

_Exit:
  //
  // Release Resources
  //
  PKCS7_free (Pkcs7);

  if (!Wrapped) {
    OPENSSL_free (SignedData);
  }

  return Status;
}
