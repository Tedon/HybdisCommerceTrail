//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.4-2 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2014.10.02 at 12:23:13 PM CEST 
//


package de.hybris.platform.sap.core.jco.rec.version100.jaxb;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;
import de.hybris.platform.sap.core.jco.rec.version100.SuperToString;


/**
 * <p>Java class for Records complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Records">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element name="Element" type="{}Element"/>
 *         &lt;element name="Structure" type="{}Structure"/>
 *         &lt;element name="Table" type="{}Table"/>
 *       &lt;/choice>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Records", propOrder = {
    "elementOrStructureOrTable"
})
@XmlSeeAlso({
    TableParameterList.class,
    ExportParameterList.class,
    ChangingParameterList.class,
    ImportParameterList.class
})
public class Records
    extends SuperToString
{

    @XmlElements({
        @XmlElement(name = "Element", type = Element.class, nillable = true),
        @XmlElement(name = "Structure", type = Structure.class),
        @XmlElement(name = "Table", type = Table.class)
    })
    protected List<SuperToString> elementOrStructureOrTable;

    /**
     * Gets the value of the elementOrStructureOrTable property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the elementOrStructureOrTable property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getElementOrStructureOrTable().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Element }
     * {@link Structure }
     * {@link Table }
     * 
     * 
     */
    public List<SuperToString> getElementOrStructureOrTable() {
        if (elementOrStructureOrTable == null) {
            elementOrStructureOrTable = new ArrayList<SuperToString>();
        }
        return this.elementOrStructureOrTable;
    }

}