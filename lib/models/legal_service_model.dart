import 'dart:convert';

/// ---------- Root ----------
LegalServiceResponse legalServiceResponseFromJson(String str) =>
    LegalServiceResponse.fromJson(json.decode(str));

class LegalServiceResponse {
  final List<LegalService> content;
  final Pageable pageable;
  final int totalPages;
  final int totalElements;
  final bool last;
  final int size;
  final int number;
  final Sort sort;
  final int numberOfElements;
  final bool first;
  final bool empty;

  LegalServiceResponse({
    required this.content,
    required this.pageable,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.size,
    required this.number,
    required this.sort,
    required this.numberOfElements,
    required this.first,
    required this.empty,
  });

  factory LegalServiceResponse.fromJson(Map<String, dynamic> json) {
    return LegalServiceResponse(
      content: List<LegalService>.from(
        json["content"].map((x) => LegalService.fromJson(x)),
      ),
      pageable: Pageable.fromJson(json["pageable"]),
      totalPages: json["totalPages"],
      totalElements: json["totalElements"],
      last: json["last"],
      size: json["size"],
      number: json["number"],
      sort: Sort.fromJson(json["sort"]),
      numberOfElements: json["numberOfElements"],
      first: json["first"],
      empty: json["empty"],
    );
  }
}

/// ---------- Content ----------
class LegalService {
  final int id;
  final String code;
  final String legalName;
  final String? contactName;
  final String city;
  final String state;
  final String country;
  final String address;
  final String phone1;
  final String? phone2;
  final String email;
  final String? planPackage;
  final List<String> services;
  final String status;
  final String createdBy;
  final String updatedBy;
  final DateTime createdTs;
  final DateTime lastUpdatedTs;

  LegalService({
    required this.id,
    required this.code,
    required this.legalName,
    this.contactName,
    required this.city,
    required this.state,
    required this.country,
    required this.address,
    required this.phone1,
    this.phone2,
    required this.email,
    this.planPackage,
    required this.services,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdTs,
    required this.lastUpdatedTs,
  });

  factory LegalService.fromJson(Map<String, dynamic> json) {
    return LegalService(
      id: json["id"],
      code: json["code"],
      legalName: json["legalname"],
      contactName: json["contactname"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      address: json["address"],
      phone1: json["phone1"],
      phone2: json["phone2"],
      email: json["email"],
      planPackage: json["planPackage"],
      services: List<String>.from(json["services"]),
      status: json["status"],
      createdBy: json["createdBy"],
      updatedBy: json["updatedBy"],
      createdTs: DateTime.parse(json["createdTs"]),
      lastUpdatedTs: DateTime.parse(json["lastUpdatedTs"]),
    );
  }
}

/// ---------- Pageable ----------
class Pageable {
  final int pageNumber;
  final int pageSize;
  final Sort sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      pageNumber: json["pageNumber"],
      pageSize: json["pageSize"],
      sort: Sort.fromJson(json["sort"]),
      offset: json["offset"],
      paged: json["paged"],
      unpaged: json["unpaged"],
    );
  }
}

/// ---------- Sort ----------
class Sort {
  final bool sorted;
  final bool empty;
  final bool unsorted;

  Sort({
    required this.sorted,
    required this.empty,
    required this.unsorted,
  });

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      sorted: json["sorted"],
      empty: json["empty"],
      unsorted: json["unsorted"],
    );
  }
}
