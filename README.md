PDF/A generator
===============

This is a no-configuration converter from any PDF file into a PDF/A A-1b (using PDF 1.4 format). The metadata for `Title` and `Creator` come from the plain PDF tags `Title`and `Author`.

Any feature in the PDF that is not allowed in PDF/A is removed to ensure PDF/A conformance. Ghostscript will output warning for each occurrence of these featured in the input PDF. When converting a thesis PDF file, the most frequently features dropped by Ghostscript will likely be the PDF annotations (used among other thing to create hyperlinks).

PDF/A requires that not only fonts, but also color profiles be defined and embedded. To provide a configuration-free experience, sRGB is chosen as the profile (the `srgb.icc` file comes from Ghostscript 9.53.2 distribution).

**Warning**: This was created to satisfy PDF/A requirements made by a university library. This script has not been tested for other use cases.


FAQ
---

### What is different from http://pdfa.bu.ufsc.br/ ?

1. The output PDF passes [VeraPDF](https://verapdf.org/software/) validation
2. **No visual artifacts**. The online service causes the whole page (including text) to become pixelated when there is an image included 
2. The output PDF is 1.4 (as intended by A-1b) instead of 1.7
3. All required metadata tags are filled both in PDF and XMP
4. The color profile is defined and embedded
5. The file is usually larger

### What is different from [pdfx](https://ctan.org/pkg/pdfx)

pdfx is a LaTeX package and runs during regular compilation of the LaTeX file. The issue that motivated using Ghostscript was pdfx failure to embed Helvetica and Courier fonts (which are special fonts that should never be embedded -- except for PDF/A). Maybe that has been resolved (or maybe it is a feature).
