/*
  Unity3D Custom Hardware Interface Demo.

  Copyright (c) 2013 Dilshan R Jayakody (jayakody2000lk at gmail dot com).

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
*/
const unsigned int USB_VENDOR_ID = 0x8462;
const unsigned int USB_PRODUCT_ID = 0x0004;
const char USB_SELF_POWER = 0x80;            // Self powered 0xC0,  0x80 bus powered
const char USB_MAX_POWER = 50;               // Bus power required in units of 2 mA
const char HID_INPUT_REPORT_BYTES = 64;
const char HID_OUTPUT_REPORT_BYTES = 64;
const char USB_TRANSFER_TYPE = 0x03;         //0x03 Interrupt
const char EP_IN_INTERVAL = 1;
const char EP_OUT_INTERVAL = 1;

const char USB_INTERRUPT = 1;
const char USB_HID_EP = 1;
const char USB_HID_RPT_SIZE = 33;

/* Device Descriptor */
const struct {
    char bLength;               // bLength         - Descriptor size in bytes (12h)
    char bDescriptorType;       // bDescriptorType - The constant DEVICE (01h)
    unsigned int bcdUSB;        // bcdUSB          - USB specification release number (BCD)
    char bDeviceClass;          // bDeviceClass    - Class Code
    char bDeviceSubClass;       // bDeviceSubClass - Subclass code
    char bDeviceProtocol;       // bDeviceProtocol - Protocol code
    char bMaxPacketSize0;       // bMaxPacketSize0 - Maximum packet size for endpoint 0
    unsigned int idVendor;      // idVendor        - Vendor ID
    unsigned int idProduct;     // idProduct       - Product ID
    unsigned int bcdDevice;     // bcdDevice       - Device release number (BCD)
    char iManufacturer;         // iManufacturer   - Index of string descriptor for the manufacturer
    char iProduct;              // iProduct        - Index of string descriptor for the product.
    char iSerialNumber;         // iSerialNumber   - Index of string descriptor for the serial number.
    char bNumConfigurations;    // bNumConfigurations - Number of possible configurations
} device_dsc = {
      0x12,                   // bLength
      0x01,                   // bDescriptorType
      0x0200,                 // bcdUSB
      0x00,                   // bDeviceClass
      0x00,                   // bDeviceSubClass
      0x00,                   // bDeviceProtocol
      8,                      // bMaxPacketSize0
      USB_VENDOR_ID,          // idVendor
      USB_PRODUCT_ID,         // idProduct
      0x0001,                 // bcdDevice
      0x01,                   // iManufacturer
      0x02,                   // iProduct
      0x00,                   // iSerialNumber
      0x01                    // bNumConfigurations
  };

/* Configuration 1 Descriptor */
const char configDescriptor1[]= {
    // Configuration Descriptor
    0x09,                   // bLength             - Descriptor size in bytes
    0x02,                   // bDescriptorType     - The constant CONFIGURATION (02h)
    0x29,0x00,              // wTotalLength        - The number of bytes in the configuration descriptor and all of its subordinate descriptors
    1,                      // bNumInterfaces      - Number of interfaces in the configuration
    1,                      // bConfigurationValue - Identifier for Set Configuration and Get Configuration requests
    0,                      // iConfiguration      - Index of string descriptor for the configuration
    USB_SELF_POWER,         // bmAttributes        - Self/bus power and remote wakeup settings
    USB_MAX_POWER,          // bMaxPower           - Bus power required in units of 2 mA

    // Interface Descriptor
    0x09,                   // bLength - Descriptor size in bytes (09h)
    0x04,                   // bDescriptorType - The constant Interface (04h)
    0,                      // bInterfaceNumber - Number identifying this interface
    0,                      // bAlternateSetting - A number that identifies a descriptor with alternate settings for this bInterfaceNumber.
    2,                      // bNumEndpoint - Number of endpoints supported not counting endpoint zero
    0x03,                   // bInterfaceClass - Class code
    0,                      // bInterfaceSubclass - Subclass code
    0,                      // bInterfaceProtocol - Protocol code
    0,                      // iInterface - Interface string index

    // HID Class-Specific Descriptor
    0x09,                   // bLength - Descriptor size in bytes.
    0x21,                   // bDescriptorType - This descriptor's type: 21h to indicate the HID class.
    0x01,0x01,              // bcdHID - HID specification release number (BCD).
    0x00,                   // bCountryCode - Numeric expression identifying the country for localized hardware (BCD) or 00h.
    1,                      // bNumDescriptors - Number of subordinate report and physical descriptors.
    0x22,                   // bDescriptorType - The type of a class-specific descriptor that follows
    USB_HID_RPT_SIZE,0x00,  // wDescriptorLength - Total length of the descriptor identified above.

    // Endpoint Descriptor
    0x07,                   // bLength - Descriptor size in bytes (07h)
    0x05,                   // bDescriptorType - The constant Endpoint (05h)
    USB_HID_EP | 0x80,      // bEndpointAddress - Endpoint number and direction
    USB_TRANSFER_TYPE,      // bmAttributes - Transfer type and supplementary information    
    0x40,0x00,              // wMaxPacketSize - Maximum packet size supported
    EP_IN_INTERVAL,         // bInterval - Service interval or NAK rate

    // Endpoint Descriptor
    0x07,                   // bLength - Descriptor size in bytes (07h)
    0x05,                   // bDescriptorType - The constant Endpoint (05h)
    USB_HID_EP,             // bEndpointAddress - Endpoint number and direction
    USB_TRANSFER_TYPE,      // bmAttributes - Transfer type and supplementary information
    0x40,0x00,              // wMaxPacketSize - Maximum packet size supported    
    EP_OUT_INTERVAL         // bInterval - Service interval or NAK rate
};

const struct {
  char report[USB_HID_RPT_SIZE];
}hid_rpt_desc =
  {
     {0x06, 0x00, 0xFF,       // Usage Page = 0xFF00 (Vendor Defined Page 1)
      0x09, 0x01,             // Usage (Vendor Usage 1)
      0xA1, 0x01,             // Collection (Application)
  // Input report
      0x19, 0x01,             // Usage Minimum
      0x29, 0x40,             // Usage Maximum
      0x15, 0x00,             // Logical Minimum (data bytes in the report may have minimum value = 0x00)
      0x26, 0xFF, 0x00,       // Logical Maximum (data bytes in the report may have maximum value = 0x00FF = unsigned 255)
      0x75, 0x08,             // Report Size: 8-bit field size
      0x95, HID_INPUT_REPORT_BYTES,// Report Count
      0x81, 0x02,             // Input (Data, Array, Abs)
  // Output report
      0x19, 0x01,             // Usage Minimum
      0x29, 0x40,             // Usage Maximum
      0x75, 0x08,             // Report Size: 8-bit field size
      0x95, HID_OUTPUT_REPORT_BYTES,// Report Count
      0x91, 0x02,             // Output (Data, Array, Abs)
      0xC0}                   // End Collection
  };

//Language code string descriptor
const struct {
  char bLength;
  char bDscType;
  unsigned int string[1];
  } strd1 = {
      4,
      0x03,
      {0x0409}
    };


//Manufacturer string descriptor
const struct{
  char bLength;
  char bDscType;
  unsigned int string[16];
  }strd2={
    34,           //sizeof this descriptor string
    0x03,
    {'D','i','l','s','h','a','n',' ','J','a','y','a','k','o','d','y'}
  };

//Product string descriptor
const struct{
  char bLength;
  char bDscType;
  unsigned int string[18];
}strd3={
    38,          //sizeof this descriptor string
    0x03,
    {'U','n','i','t','y','3','D',' ','C','o','n','t','r','o','l','l','e','r'}
 };

//Array of configuration descriptors
const char* USB_config_dsc_ptr[1];

//Array of string descriptors
const char* USB_string_dsc_ptr[3];

void USB_Init_Desc(){
  USB_config_dsc_ptr[0] = &configDescriptor1;
  USB_string_dsc_ptr[0] = (const char*)&strd1;
  USB_string_dsc_ptr[1] = (const char*)&strd2;
  USB_string_dsc_ptr[2] = (const char*)&strd3;
}