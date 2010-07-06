///////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2007, 2010 Michael A. Jackson for BlueQuartz Software
//  All rights reserved.
//  BSD License: http://www.opensource.org/licenses/bsd-license.html
//
//  This code was written under United States Air Force Contract number
//                           F33615-03-C-5220
//
///////////////////////////////////////////////////////////////////////////////
#ifndef _CrossCorrelation_THREAD_H_
#define _CrossCorrelation_THREAD_H_


//-- C++ Includes
#include <string>

//-- ITK Includes
#include <itkImportImageFilter.h>

//--MXA Includes
#include <MXA/Common/LogTime.h>
#include <MXA/Common/MXASetGetMacros.h>

// Our Includes
#include "AIM/Common/AIMImage.h"
#include "CrossCorrelation/CrossCorrelationData.h"

#include "CrossCorrelation/pcm/itkPhaseCorrelationImageRegistrationMethod.h"

//-- ITK Typedefs
namespace R3D
{
  namespace PCM
  {
    const unsigned int FFTResolutionSize = 14;
    const float        PCMAbsolutePixelOffset = 3.0f;
  }
}
//typedef unsigned char PixelType;
typedef unsigned char                                               UCharPixelType;
typedef itk::Image<UCharPixelType, pcm::Dimension>                  UCharImageType;
typedef float                                                       FFTPixelType;
typedef itk::Image< FFTPixelType, pcm::Dimension >                  FFTImageType;


typedef itk::ImportImageFilter<UCharPixelType, pcm::Dimension>     ImportFilterType;



/**
* @class CrossCorrelation CrossCorrelation.h CrossCorrelation/CrossCorrelation.h
* @brief Higher level class that utilizes the itk::PCM classes to register 2 images
* relative to each other. The input and output data (translations) are stored in
* the 'CrossCorrelationData' class. Input images are fed to the class as 'AIMImage'
* class instances (shared pointer classes). Use the 'run' method to execute the
* filter when all the inputs have beed set correctly. Use the 'getErrorCondition'
* method after the 'run' method returns in order to figure out if there was an
* error during the registration.
* @author Michael Jackson For Bluequartz Software
* @date June 2009
* @version 1.0
*/
class CrossCorrelation
{
  public:

    MXA_SHARED_POINTERS(CrossCorrelation)
    MXA_STATIC_NEW_MACRO(CrossCorrelation);
    MXA_TYPE_MACRO(CrossCorrelation)

    virtual ~CrossCorrelation();

    /**
     * @brief Sets the 'CrossCorrelationData' object.
     */
    MXA_INSTANCE_PROPERTY_m(CrossCorrelationData::Pointer, CrossCorrelationData)

    /**
     * @brief Sets the debug property. Setting this to true will make this class
     * write more verbose output to the standard out.
     */
    MXA_INSTANCE_PROPERTY_m(bool, Debug)

    /**
     * @brief Sets and Gets the Error condition variable. Values < 0 indicate that
     * and error occurred during the registration process.
     */
    MXA_INSTANCE_PROPERTY_m(int, ErrorCondition)

    /**
     * @brief Sets/Gets the Fixed Image object of the registration pair
     */
    MXA_INSTANCE_PROPERTY_m(AIMImage::Pointer, FixedImage)

    /**
     * @brief Sets/Gets the Moving Image object of the registration pair.
     */
    MXA_INSTANCE_PROPERTY_m(AIMImage::Pointer, MovingImage)


    /**
     * @brief main entry point to register the 2 images
     * @return Negative value on error.
     */
    void run();

    /**
     * @brief Writes the given Image to a file using the translations stored in the
     * CrossCorrelationData object. This may result in the image being clipped or
     * shifted resulting in some of the original input image NOT being within the
     * writable region of the image.
     * @param image The input image
     * @param ccData The CrossCorrelationData object that stores the translations
     * @param filename The path & name to the output file.
     * @return Error condition. Negative values represent an error.
     */
    int writeRegisteredImage(AIMImage::Pointer image,
                         CrossCorrelationData::Pointer ccData,
                         const std::string &filename);

  protected:
    /**
     * @brief Constructor for this object.
     * @return
     */
    CrossCorrelation();

    /**
     * @brief Registers the fixed and moving images using the supplied FFT dimension.
     * @param fftDim The size of the image which should be one of the set FFT Dimensions
     * @return Negative value on Error
     */
    int32_t registerAtFFTResolution(int fftDim );

    /**
     * @brief
     * @param image
     * @param importFilter
     * @param ccData
     * @param isFixedImage
     */
    void itkImportFilterFromAIMImage(AIMImage::Pointer image,
                                     ImportFilterType::Pointer importFilter,
                                     CrossCorrelationData::Pointer ccData,
                                     bool isFixedImage);


    /**
     * @brief Initializes the itkImportFilter object with the correct size, spacing and origin information
     * @param importFilter The ImportFilterType object to be initialized
     * @param imageData A pointer to the raw image data
     * @param sliceInfo A Shared Pointer to the R3DSliceInfo Object
     */
    void initializeImportFilter(ImportFilterType::Pointer importFilter,
                                int fftDim,
                                AIMImage::Pointer imageData,
                                bool isFixedImage);

    /**
     * @brief This will actually register 2 images
     * @param fxImageImport The itkImportFilter representing the fixed image
     * @param fixedSliceInfo The Zeiss Slice Info for the fixed image
     * @param mvImageImport The itkImportFilter representing the moving image
     * @param movingSliceInfo The Zeiss Slice Info for the moving image
     * @return
     */
    int registerImages(ImportFilterType::Pointer fxImageImport,
                       ImportFilterType::Pointer mvImageImport );


    /**
     * @brief Creates an image that is written out to disk
     * @param path The path to the output image
     * @param slice The slice number
     * @param num The frame number
     * @param label Extra label for the filename
     * @return Absolute path to the output image
     */
    std::string makeAnalysisImage(const std::string &path,
                                   const std::string &slice,
                                   const std::string &num,
                                   const std::string &label);

    /**
     * @brief This will create the Correlation Images from the data. Primarily used for debugging
     * @param fxImport Fixed Image
     * @param mvImport Moving Image
     */
    void createCorrelationImages(  ImportFilterType::Pointer fxImport,
                                   ImportFilterType::Pointer mvImport);
  private:

    int                          m_FFTResolutions[R3D::PCM::FFTResolutionSize];
    float                        m_AllowableError;

    CrossCorrelation(const CrossCorrelation&); // Copy Constructor Not Implemented
    void operator=(const CrossCorrelation&); // Operator '=' Not Implemented
};


#endif /* _CrossCorrelation_THREAD_H_ */
